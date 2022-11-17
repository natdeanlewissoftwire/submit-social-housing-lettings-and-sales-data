class LocationDeactivationPeriod < ApplicationRecord
  scope :deactivations_without_reactivation, -> { where(reactivation_date: nil) }
end