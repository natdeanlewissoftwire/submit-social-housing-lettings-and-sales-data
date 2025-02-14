module Validations::DateValidations
  include Validations::SharedValidations

  def validate_property_major_repairs(record)
    date_valid?("mrcdate", record)
    if record["startdate"].present? && record["mrcdate"].present? && record["startdate"] < record["mrcdate"]
      record.errors.add :mrcdate, I18n.t("validations.property.mrcdate.before_tenancy_start")
    end

    if is_rsnvac_first_let?(record) && record["mrcdate"].present?
      record.errors.add :mrcdate, I18n.t("validations.property.mrcdate.not_first_let")
    end

    if record["mrcdate"].present? && record["startdate"].present? && record["startdate"].to_date - record["mrcdate"].to_date > 3650
      record.errors.add :mrcdate, I18n.t("validations.property.mrcdate.ten_years_before_tenancy_start")
    end
  end

  def validate_property_void_date(record)
    if record["voiddate"].present? && record["startdate"].present? && record["startdate"].to_date - record["voiddate"].to_date > 3650
      record.errors.add :voiddate, I18n.t("validations.property.void_date.ten_years_before_tenancy_start")
    end

    if record["voiddate"].present? && record["startdate"].present? && record["startdate"].to_date < record["voiddate"].to_date
      record.errors.add :voiddate, I18n.t("validations.property.void_date.before_tenancy_start")
    end

    if record["voiddate"].present? && record["mrcdate"].present? && record["mrcdate"].to_date < record["voiddate"].to_date
      record.errors.add :voiddate, I18n.t("validations.property.void_date.after_mrcdate")
    end
  end

  def validate_startdate(record)
    return unless record.startdate && date_valid?("startdate", record)

    created_at = record.created_at || Time.zone.now

    if created_at > first_collection_end_date && record.startdate < second_collection_start_date
      record.errors.add :startdate, I18n.t("validations.date.outside_collection_window")
    end

    if (record.startdate < first_collection_start_date || record.startdate > second_collection_end_date) && FeatureToggle.startdate_collection_window_validation_enabled?
      record.errors.add :startdate, I18n.t("validations.date.outside_collection_window")
    end

    if FeatureToggle.startdate_two_week_validation_enabled? && record.startdate > Time.zone.today + 14
      record.errors.add :startdate, I18n.t("validations.setup.startdate.later_than_14_days_after")
    end

    if record.scheme_id.present?
      scheme_end_date = record.scheme.end_date
      if scheme_end_date.present? && record.startdate > scheme_end_date
        record.errors.add :startdate, I18n.t("validations.setup.startdate.before_scheme_end_date")
      end
    end

    if record["voiddate"].present? && record.startdate < record["voiddate"]
      record.errors.add :startdate, I18n.t("validations.setup.startdate.after_void_date")
    end

    if record["mrcdate"].present? && record.startdate < record["mrcdate"]
      record.errors.add :startdate, I18n.t("validations.setup.startdate.after_major_repair_date")
    end

    location_during_startdate_validation(record, :startdate)
    scheme_during_startdate_validation(record, :startdate)
  end

private

  def first_collection_start_date
    @first_collection_start_date ||= FormHandler.instance.lettings_forms["previous_lettings"].start_date
  end

  def first_collection_end_date
    @first_collection_end_date ||= FormHandler.instance.lettings_forms["previous_lettings"].end_date
  end

  def second_collection_start_date
    @second_collection_start_date ||= FormHandler.instance.lettings_forms["current_lettings"].start_date
  end

  def second_collection_end_date
    @second_collection_end_date ||= FormHandler.instance.lettings_forms["current_lettings"].end_date
  end

  def is_rsnvac_first_let?(record)
    [15, 16, 17].include?(record["rsnvac"])
  end
end
