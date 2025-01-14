require "rails_helper"

RSpec.describe Validations::PropertyValidations do
  subject(:property_validator) { property_validator_class.new }

  let(:property_validator_class) { Class.new { include Validations::PropertyValidations } }
  let(:record) { FactoryBot.create(:lettings_log) }

  describe "#validate_property_number_of_times_relet" do
    let(:expected_error) { I18n.t("validations.property.offered.relet_number") }

    it "does not add an error if the record offered is missing" do
      record.offered = nil
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
    end

    it "does not add an error if offered is valid (number between 0 and 20)" do
      record.offered = 0
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
      record.offered = 10
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
      record.offered = 20
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
    end

    it "does add an error when offered is invalid" do
      record.offered = "invalid"
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).not_to be_empty
      expect(record.errors["offered"]).to include(match(expected_error))
      record.offered = 21
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).not_to be_empty
      expect(record.errors["offered"]).to include(match(expected_error))
    end
  end

  describe "#validate_shared_housing_rooms" do
    context "when number of bedrooms has not been answered" do
      it "does not add an error" do
        record.beds = nil
        record.unittype_gn = 2
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors).to be_empty
      end
    end

    context "when unit type is shared and number of bedrooms has not been answered" do
      it "does not add an error" do
        record.beds = nil
        record.unittype_gn = 10
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors).to be_empty
      end
    end

    context "when unit type has not been answered" do
      it "does not add an error" do
        record.beds = 2
        record.unittype_gn = nil
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors).to be_empty
      end
    end

    context "when a bedsit has more than 1 bedroom" do
      let(:expected_error) { I18n.t("validations.property.unittype_gn.one_bedroom_bedsit") }

      it "adds an error" do
        record.beds = 2
        record.unittype_gn = 2
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors["unittype_gn"]).to include(match(expected_error))
        expect(record.errors["beds"]).to include(I18n.t("validations.property.unittype_gn.one_bedroom_bedsit"))
      end
    end

    context "when a bedsit has less than 1 bedroom" do
      let(:expected_error) { I18n.t("validations.property.unittype_gn.one_bedroom_bedsit") }

      it "adds an error" do
        record.beds = 0
        record.unittype_gn = 2
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors["unittype_gn"]).to include(match(expected_error))
        expect(record.errors["beds"]).to include(I18n.t("validations.property.unittype_gn.one_bedroom_bedsit"))
      end
    end

    context "when shared housing has more than 7 bedrooms" do
      let(:expected_error) { I18n.t("validations.property.unittype_gn.one_seven_bedroom_shared") }

      it "adds an error if the number of bedrooms is not between 1 and 7" do
        record.beds = 8
        record.unittype_gn = 9
        record.hhmemb = 3
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors["unittype_gn"]).to include(match(expected_error))
        expect(record.errors["beds"]).to include(I18n.t("validations.property.unittype_gn.one_seven_bedroom_shared"))
      end
    end

    context "when shared housing has less than 1 bedrooms" do
      let(:expected_error) { I18n.t("validations.property.unittype_gn.one_seven_bedroom_shared") }

      it "adds an error if the number of bedrooms is not between 1 and 7" do
        record.beds = 0
        record.unittype_gn = 9
        record.hhmemb = 3
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors["unittype_gn"]).to include(match(expected_error))
        expect(record.errors["beds"]).to include(I18n.t("validations.property.unittype_gn.one_seven_bedroom_shared"))
      end
    end

    context "when there are too many bedrooms for the number of household members and unit type" do
      let(:expected_error) { I18n.t("validations.property.unittype_gn.one_three_bedroom_single_tenant_shared") }

      it "adds an error" do
        record.beds = 4
        record.unittype_gn = 9
        record.hhmemb = 1
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors["unittype_gn"]).to include(match(expected_error))
        expect(record.errors["beds"]).to include(I18n.t("validations.property.unittype_gn.one_three_bedroom_single_tenant_shared"))
      end
    end

    context "when a negative number of bedrooms is entered" do
      it "adds an error" do
        record.beds = -4
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors["beds"]).to include(I18n.t("validations.property.beds.non_positive"))
      end
    end

    context "when a room number higher than 12 has been entered" do
      it "adds an error" do
        record.beds = 13
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors["beds"]).to include(I18n.t("validations.property.beds.over_max"))
      end
    end
  end

  describe "#validate_unitletas" do
    context "when the property has not been let before" do
      it "validates that no previous let type is provided" do
        record.first_time_property_let_as_social_housing = 1
        record.unitletas = 0
        property_validator.validate_unitletas(record)
        expect(record.errors["unitletas"])
          .to include(match I18n.t("validations.property.rsnvac.previous_let_social"))
        record.unitletas = 1
        property_validator.validate_unitletas(record)
        expect(record.errors["unitletas"])
          .to include(match I18n.t("validations.property.rsnvac.previous_let_social"))
        record.unitletas = 2
        property_validator.validate_unitletas(record)
        expect(record.errors["unitletas"])
          .to include(match I18n.t("validations.property.rsnvac.previous_let_social"))
        record.unitletas = 3
        property_validator.validate_unitletas(record)
        expect(record.errors["unitletas"])
          .to include(match I18n.t("validations.property.rsnvac.previous_let_social"))
      end
    end

    context "when the property has been let previously" do
      it "expects to have a previous let type" do
        record.first_time_property_let_as_social_housing = 0
        record.unitletas = 0
        property_validator.validate_unitletas(record)
        expect(record.errors["unitletas"]).to be_empty
      end
    end
  end

  describe "validate_rsnvac" do
    context "when the property has not been let before" do
      it "validates that it has a first let reason for vacancy" do
        record.first_time_property_let_as_social_housing = 1
        record.rsnvac = 6
        property_validator.validate_rsnvac(record)
        expect(record.errors["rsnvac"])
          .to include(match I18n.t("validations.property.rsnvac.first_let_social"))
      end

      it "expects to have a first let reason for vacancy" do
        record.first_time_property_let_as_social_housing = 1
        record.rsnvac = 15
        property_validator.validate_rsnvac(record)
        expect(record.errors["rsnvac"]).to be_empty
        record.rsnvac = 16
        property_validator.validate_rsnvac(record)
        expect(record.errors["rsnvac"]).to be_empty
        record.rsnvac = 17
        property_validator.validate_rsnvac(record)
        expect(record.errors["rsnvac"]).to be_empty
      end
    end

    context "when the property has been let as social housing before" do
      it "validates that the reason for vacancy is not a first let as social housing reason" do
        record.first_time_property_let_as_social_housing = 0
        record.rsnvac = 15
        property_validator.validate_rsnvac(record)
        expect(record.errors["rsnvac"])
          .to include(match I18n.t("validations.property.rsnvac.first_let_not_social"))
        record.rsnvac = 16
        property_validator.validate_rsnvac(record)
        expect(record.errors["rsnvac"])
          .to include(match I18n.t("validations.property.rsnvac.first_let_not_social"))
        record.rsnvac = 17
        property_validator.validate_rsnvac(record)
        expect(record.errors["rsnvac"])
          .to include(match I18n.t("validations.property.rsnvac.first_let_not_social"))
      end

      it "expects the reason for vacancy to be a first let as social housing reason" do
        record.first_time_property_let_as_social_housing = 1
        record.rsnvac = 15
        property_validator.validate_rsnvac(record)
        expect(record.errors["rsnvac"]).to be_empty
        record.rsnvac = 16
        property_validator.validate_rsnvac(record)
        expect(record.errors["rsnvac"]).to be_empty
        record.rsnvac = 17
        property_validator.validate_rsnvac(record)
        expect(record.errors["rsnvac"]).to be_empty
      end

      context "when the letting is not a renewal" do
        it "validates that the reason for vacancy is not renewal" do
          record.first_time_property_let_as_social_housing = 0
          record.renewal = 0
          record.rsnvac = 14
          property_validator.validate_rsnvac(record)
          expect(record.errors["rsnvac"])
                .to include(match I18n.t("validations.property.rsnvac.not_a_renewal"))
        end
      end
    end

    context "when the property has been let before" do
      let(:non_temporary_previous_tenancies) { [4, 5, 16, 21, 22] }

      context "when the previous tenancy was not temporary" do
        let(:referral_sources) { described_class::REFERRAL_INVALID_TMP }

        it "validates that the property is not being relet to tenant who occupied as temporary" do
          non_temporary_previous_tenancies.each do |prevten|
            record.rsnvac = 9
            record.prevten = prevten
            property_validator.validate_rsnvac(record)
            expect(record.errors["rsnvac"])
              .to include(match I18n.t("validations.property.rsnvac.non_temp_accommodation"))
          end
        end

        it "validates that the letting source is not a referral" do
          referral_sources.each do |src|
            record.rsnvac = 9
            record.referral = src
            property_validator.validate_rsnvac(record)
            expect(record.errors["rsnvac"])
              .to include(match I18n.t("validations.property.rsnvac.referral_invalid"))
          end
        end
      end

      context "when the previous tenancy was temporary" do
        it "expects that the property can be relet to a tenant who previously occupied it as temporary" do
          record.prevten = 0
          record.rsnvac = 2
          property_validator.validate_rsnvac(record)
          expect(record.errors["rsnvac"]).to be_empty
        end

        it "expects that the letting source can be a referral" do
          record.prevten = 0
          record.referral = 2
          property_validator.validate_rsnvac(record)
          expect(record.errors["rsnvac"]).to be_empty
        end
      end
    end
  end
end
