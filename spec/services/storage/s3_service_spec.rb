require "rails_helper"

RSpec.describe Storage::S3Service do
  let(:instance_name) { "instance_1" }
  let(:bucket_name) { "bucket_1" }
  let(:vcap_services) do
    <<-JSON
        {"aws-s3-bucket": [
          {
            "instance_name": "#{instance_name}",
            "credentials": {
              "aws_access_key_id": "key_id",
              "aws_region": "eu-west-2",
              "aws_secret_access_key": "secret",
              "bucket_name": "#{bucket_name}"
            }
          }
        ]}
    JSON
  end

  context "when we create a storage service with no PaaS Configuration present" do
    subject(:storage_service) { described_class.new(Configuration::PaasConfigurationService.new, "random_instance") }

    it "raises an exception" do
      expect { storage_service }.to raise_error(RuntimeError, "No S3 bucket is present in the PaaS configuration")
    end
  end

  context "when we create a storage service and the S3 instance name is not found in the PaaS configuration" do
    subject(:storage_service) { described_class.new(Configuration::PaasConfigurationService.new, "random_instance") }

    let(:vcap_services) do
      <<-JSON
        {"aws-s3-bucket": []}
      JSON
    end

    before do
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return(vcap_services)
    end

    it "raises an exception" do
      expect { storage_service }.to raise_error(RuntimeError, /instance name could not be found/)
    end
  end

  context "when we create a storage service with a valid instance name" do
    subject(:storage_service) { described_class.new(Configuration::PaasConfigurationService.new, instance_name) }

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return(vcap_services)
    end

    it "creates a Storage Configuration" do
      expect(storage_service.configuration).to be_an(Storage::StorageConfiguration)
    end

    it "sets the expected parameters in the configuration" do
      expected_configuration = Storage::StorageConfiguration.new(
        {
          aws_access_key_id: "key_id",
          aws_region: "eu-west-2",
          aws_secret_access_key: "secret",
          bucket_name:,
        },
      )
      expect(storage_service.configuration).to eq(expected_configuration)
    end
  end

  context "when we create a storage service and write a stubbed object" do
    subject(:storage_service) { described_class.new(Configuration::PaasConfigurationService.new, instance_name) }

    let(:filename) { "my_file" }
    let(:content) { "content" }
    let(:s3_client_stub) { Aws::S3::Client.new(stub_responses: true) }

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return(vcap_services)
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client_stub)
    end

    it "retrieves the previously written object successfully if it exists" do
      s3_client_stub.stub_responses(:get_object, { body: content })

      data = storage_service.get_file_io(filename)
      expect(data.string).to eq(content)
    end

    it "fails when the object does not exist" do
      s3_client_stub.stub_responses(:get_object, "NoSuchKey")

      expect { storage_service.get_file_io("fake_filename") }
        .to raise_error(Aws::S3::Errors::NoSuchKey)
    end

    it "writes to the storage with the expected parameters" do
      expect(s3_client_stub).to receive(:put_object).with(body: content,
                                                          bucket: bucket_name,
                                                          key: filename)
      storage_service.write_file(filename, content)
    end
  end

  context "when we create a storage service" do
    subject(:storage_service) { described_class.new(Configuration::PaasConfigurationService.new, instance_name) }

    let(:s3_client_stub) { Aws::S3::Client.new(stub_responses: true) }

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return(vcap_services)
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client_stub)
    end

    context "and we list files based on a prefix" do
      let(:expected_filenames) { %w[my_folder/my_file1.xml my_folder/my_file2.xml] }

      before do
        s3_client_stub.stub_responses(:list_objects_v2, {
          contents: [
            {
              key: expected_filenames[0],
            },
            {
              key: expected_filenames[1],
            },
          ],
        })
      end

      it "returns a list with all present file names in a given folder" do
        filenames = storage_service.list_files("my_folder")
        expect(filenames).to eq(expected_filenames)
      end
    end

    context "and we check for an existing folder" do
      before do
        expected_filenames = %w[my_folder/my_file1.xml]
        s3_client_stub.stub_responses(:list_objects_v2, {
          key_count: 1,
          contents: [
            {
              key: expected_filenames[0],
            },
          ],
        })
      end

      it "returns true" do
        response = storage_service.folder_present?("my_folder")
        expect(response).to be_truthy
      end
    end

    context "and we check for a folder that does not exists" do
      before do
        s3_client_stub.stub_responses(:list_objects_v2, {
          key_count: 0,
          contents: [],
        })
      end

      it "returns false" do
        response = storage_service.folder_present?("my_folder")
        expect(response).to be_falsey
      end
    end
  end
end
