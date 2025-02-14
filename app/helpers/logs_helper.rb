module LogsHelper
  def log_type_for_controller(controller)
    case controller.class.to_s
    when "LettingsLogsController"
      "lettings"
    when "SalesLogsController"
      "sales"
    else
      raise "Log type not found for #{controller.class}"
    end
  end

  def bulk_upload_path_for_controller(controller, id:)
    case log_type_for_controller(controller)
    when "lettings"
      bulk_upload_lettings_log_path(id:)
    when "sales"
      bulk_upload_sales_log_path(id:)
    end
  end

  def bulk_upload_options(bulk_upload)
    array = bulk_upload ? [bulk_upload.id] : []
    array.index_with { |_bulk_upload_id| "With logs from bulk upload" }
  end
end
