require "rails_helper"

RSpec.describe BulkUploadController, type: :request do
  let(:url) { "/lettings-logs/bulk-upload" }
  let(:user) { FactoryBot.create(:user) }
  let(:organisation) { user.organisation }
  let(:valid_file) { fixture_file_upload("2021_22_lettings_bulk_upload.xlsx", "application/vnd.ms-excel") }
  let(:invalid_file) { fixture_file_upload("random.txt", "text/plain") }
  let(:empty_file) { fixture_file_upload("2021_22_lettings_bulk_upload_empty.xlsx", "application/vnd.ms-excel") }

  before do
    allow(Organisation).to receive(:find).with(107_242).and_return(organisation)
  end

  context "when a user is not signed in" do
    describe "GET #start" do
      before { get start_bulk_upload_lettings_logs_path, headers:, params: {} }

      it "does not let you see the bulk upload page" do
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "GET #show" do
      before { get url, headers:, params: {} }

      it "does not let you see the bulk upload page" do
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "POST #bulk upload" do
      before { post url, params: { bulk_upload: { lettings_log_bulk_upload: valid_file } } }

      it "does not let you submit bulk uploads" do
        expect(response).to redirect_to("/account/sign-in")
      end
    end
  end

  context "when a user is signed in" do
    before do
      sign_in user
    end

    describe "GET #show" do
      before do
        get url, params: {}
      end

      it "returns a success response" do
        expect(response).to be_successful
      end

      it "returns a page with a file upload form" do
        expect(response.body).to match(/<input id="legacy-bulk-upload-lettings-log-bulk-upload-field" class="govuk-file-upload"/)
        expect(response.body).to match(/<button type="submit" formnovalidate="formnovalidate" class="govuk-button"/)
      end
    end

    describe "GET #start" do
      before do
        Timecop.freeze(time)
        get start_bulk_upload_lettings_logs_path
      end

      after do
        Timecop.unfreeze
      end

      context "when not crossover period" do
        let(:time) { Time.utc(2022, 2, 8) }

        it "redirects to bulk upload path" do
          expect(request).to redirect_to(
            bulk_upload_lettings_log_path(
              id: "prepare-your-file",
              form: { year: 2021 },
            ),
          )
        end
      end

      context "when crossover period" do
        let(:time) { Time.utc(2022, 6, 8) }

        it "redirects to bulk upload path" do
          expect(request).to redirect_to(
            bulk_upload_lettings_log_path(id: "year"),
          )
        end
      end
    end

    describe "POST #bulk upload" do
      context "with a valid file based on the upload template" do
        let(:request) { post url, params: { bulk_upload: { lettings_log_bulk_upload: valid_file } } }

        it "creates lettings logs for each row in the template" do
          expect { request }.to change(LettingsLog, :count).by(9)
        end

        it "redirects to the lettings log index page" do
          expect(request).to redirect_to(lettings_logs_path)
        end
      end

      context "with an invalid file type" do
        before { post url, params: { bulk_upload: { lettings_log_bulk_upload: invalid_file } } }

        it "displays an error message" do
          expect(response.body).to match(/Invalid file type/)
        end
      end

      context "with an empty file" do
        let(:request) { post url, params: { bulk_upload: { lettings_log_bulk_upload: empty_file } } }

        it "displays an error message" do
          request
          expect(response.body).to match(/No data found/)
        end
      end
    end
  end
end
