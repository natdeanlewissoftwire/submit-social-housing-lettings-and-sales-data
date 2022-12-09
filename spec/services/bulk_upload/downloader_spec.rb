require "rails_helper"

RSpec.describe BulkUpload::Downloader do
  subject(:downloader) { described_class.new(bulk_upload:) }

  let(:bulk_upload) { build(:bulk_upload) }

  let(:get_file_io) do
    io = StringIO.new
    io.write("hello")
    io.rewind
    io
  end

  # rubocop:disable RSpec/PredicateMatcher
  describe "#call" do
    let(:mock_storage_service) { instance_double(Storage::S3Service, get_file_io:) }

    it "downloads the file as a temporary file" do
      allow(Storage::S3Service).to receive(:new).and_return(mock_storage_service)

      downloader.call

      expect(mock_storage_service).to have_received(:get_file_io).with(bulk_upload.identifier)

      expect(File.exist?(downloader.path)).to be_truthy
      expect(File.read(downloader.path)).to eql("hello")
    end
  end
  # rubocop:enable RSpec/PredicateMatcher
end