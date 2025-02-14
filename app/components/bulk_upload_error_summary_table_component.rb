class BulkUploadErrorSummaryTableComponent < ViewComponent::Base
  DISPLAY_THRESHOLD = 16

  attr_reader :bulk_upload

  def initialize(bulk_upload:)
    @bulk_upload = bulk_upload

    super
  end

  def sorted_errors
    @sorted_errors ||= bulk_upload
      .bulk_upload_errors
      .group(:col, :field, :error)
      .having("count(*) > ?", display_threshold)
      .count
      .sort_by { |el| el[0][0].rjust(3, "0") }
  end

  def errors?
    sorted_errors.present?
  end

private

  def display_threshold
    DISPLAY_THRESHOLD
  end
end
