require "rails_helper"

RSpec.describe BulkUploadMailer do
  subject(:mailer) { described_class.new }

  let(:notify_client) { instance_double(Notifications::Client) }
  let(:user) { create(:user, email: "user@example.com") }
  let(:bulk_upload) { build(:bulk_upload, :lettings, user:) }

  before do
    allow(Notifications::Client).to receive(:new).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  describe "#send_bulk_upload_complete_mail" do
    it "sends correctly formed email" do
      expect(notify_client).to receive(:send_email).with(
        email_address: user.email,
        template_id: described_class::BULK_UPLOAD_COMPLETE_TEMPLATE_ID,
        personalisation: {
          title: "You’ve successfully uploaded 0 logs",
          filename: bulk_upload.filename,
          upload_timestamp: bulk_upload.created_at,
          success_description: "The lettings 2022/23 data you uploaded has been checked. The 0 logs you uploaded are now complete.",
          logs_link: lettings_logs_url,
        },
      )

      mailer.send_bulk_upload_complete_mail(user:, bulk_upload:)
    end
  end

  describe "#send_bulk_upload_failed_service_error_mail" do
    it "sends correctly formed email" do
      expect(notify_client).to receive(:send_email).with(
        email_address: user.email,
        template_id: described_class::BULK_UPLOAD_FAILED_SERVICE_ERROR_TEMPLATE_ID,
        personalisation: {
          filename: bulk_upload.filename,
          upload_timestamp: bulk_upload.created_at,
          lettings_or_sales: bulk_upload.log_type,
          year_combo: bulk_upload.year_combo,
          bulk_upload_link: start_bulk_upload_lettings_logs_url,
        },
      )

      mailer.send_bulk_upload_failed_service_error_mail(bulk_upload:)
    end
  end

  context "when bulk upload has log which is not completed" do
    before do
      create(:lettings_log, :in_progress, bulk_upload:)
    end

    describe "#send_bulk_upload_with_errors_mail" do
      let(:error_description) do
        "We created logs from your 2022/23 lettings data. There was a problem with 1 of the logs. Click the below link to fix these logs."
      end

      it "sends correctly formed email" do
        expect(notify_client).to receive(:send_email).with(
          email_address: bulk_upload.user.email,
          template_id: described_class::BULK_UPLOAD_WITH_ERRORS_TEMPLATE_ID,
          personalisation: {
            title: "We found 1 log with errors",
            filename: bulk_upload.filename,
            upload_timestamp: bulk_upload.created_at.to_fs(:govuk_date_and_time),
            error_description:,
            summary_report_link: "http://localhost:3000/lettings-logs/bulk-upload-results/#{bulk_upload.id}/resume",
          },
        )

        mailer.send_bulk_upload_with_errors_mail(bulk_upload:)
      end
    end
  end
end