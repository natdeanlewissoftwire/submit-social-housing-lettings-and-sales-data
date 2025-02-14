require "securerandom"

FactoryBot.define do
  factory :bulk_upload do
    user
    log_type { BulkUpload.log_types.values.sample }
    year { 2022 }
    identifier { SecureRandom.uuid }
    sequence(:filename) { |n| "bulk-upload-#{n}.csv" }
    needstype { 1 }

    trait(:sales) do
      log_type { BulkUpload.log_types[:sales] }
    end

    trait(:lettings) do
      log_type { BulkUpload.log_types[:lettings] }
    end
  end
end
