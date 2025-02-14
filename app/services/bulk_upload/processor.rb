class BulkUpload::Processor
  attr_reader :bulk_upload

  def initialize(bulk_upload:)
    @bulk_upload = bulk_upload
  end

  def call
    download

    return send_failure_mail if validator.invalid?

    validator.call

    create_logs if validator.create_logs?
    send_correct_and_upload_again_mail unless validator.create_logs?

    send_fix_errors_mail if created_logs_but_incompleted?
    send_success_mail if created_logs_and_all_completed?
  rescue StandardError => e
    Sentry.capture_exception(e)
    send_failure_mail
  ensure
    downloader.delete_local_file!
  end

private

  def send_correct_and_upload_again_mail
    BulkUploadMailer.send_correct_and_upload_again_mail(bulk_upload:).deliver_later
  end

  def send_fix_errors_mail
    BulkUploadMailer.send_bulk_upload_with_errors_mail(bulk_upload:).deliver_later
  end

  def send_success_mail
    BulkUploadMailer.send_bulk_upload_complete_mail(user:, bulk_upload:).deliver_later
  end

  def created_logs_but_incompleted?
    validator.create_logs? && bulk_upload.logs.where.not(status: %w[completed]).count.positive?
  end

  def created_logs_and_all_completed?
    validator.create_logs? && bulk_upload.logs.group(:status).count.keys == %w[completed]
  end

  def send_failure_mail
    BulkUploadMailer.send_bulk_upload_failed_service_error_mail(bulk_upload:).deliver_later
  end

  def user
    bulk_upload.user
  end

  def create_logs
    log_creator_class.new(
      bulk_upload:,
      path: downloader.path,
    ).call
  end

  def log_creator_class
    case bulk_upload.log_type
    when "lettings"
      BulkUpload::Lettings::LogCreator
    when "sales"
      BulkUpload::Sales::LogCreator
    else
      raise "Log creator not found for #{bulk_upload.log_type}"
    end
  end

  def downloader
    @downloader ||= BulkUpload::Downloader.new(bulk_upload:)
  end

  def download
    downloader.call
  end

  def validator
    @validator ||= validator_class.new(
      bulk_upload:,
      path: downloader.path,
    )
  end

  def validator_class
    case bulk_upload.log_type
    when "lettings"
      BulkUpload::Lettings::Validator
    when "sales"
      BulkUpload::Sales::Validator
    else
      raise "Validator not found for #{bulk_upload.log_type}"
    end
  end
end
