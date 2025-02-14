require "rails_helper"

RSpec.describe Csv::LettingsLogCsvService do
  context "when the user is support" do
    let(:user) { FactoryBot.create(:user, :support) }
    let(:real_2021_2022_form) { Form.new("config/forms/2021_2022.json") }

    before do
      LettingsLog.create!(startdate: "2021-10-10", created_at: Time.utc(2022, 2, 8, 16, 52, 15))
      allow(FormHandler.instance).to receive(:get_form).and_return(real_2021_2022_form)
    end

    it "sets csv attributes in correct order" do
      expected_csv_attributes = %w[id
                                   status
                                   created_at
                                   updated_at
                                   created_by_name
                                   is_dpo
                                   owning_organisation_name
                                   managing_organisation_name
                                   collection_start_year
                                   needstype
                                   renewal
                                   startdate
                                   rent_type_detail
                                   irproduct_other
                                   tenancycode
                                   propcode
                                   postcode_known
                                   postcode_full
                                   is_la_inferred
                                   la_label
                                   la
                                   first_time_property_let_as_social_housing
                                   unitletas
                                   rsnvac
                                   offered
                                   unittype_gn
                                   builtype
                                   wchair
                                   beds
                                   voiddate
                                   void_date_value_check
                                   majorrepairs
                                   mrcdate
                                   major_repairs_date_value_check
                                   startertenancy
                                   tenancy
                                   tenancyother
                                   tenancylength
                                   sheltered
                                   declaration
                                   hhmemb
                                   pregnancy_value_check
                                   age1_known
                                   age1
                                   sex1
                                   ethnic_group
                                   ethnic
                                   national
                                   ecstat1
                                   retirement_value_check
                                   details_known_2
                                   relat2
                                   age2_known
                                   age2
                                   sex2
                                   ecstat2
                                   details_known_3
                                   relat3
                                   age3_known
                                   age3
                                   sex3
                                   ecstat3
                                   details_known_4
                                   relat4
                                   age4_known
                                   age4
                                   sex4
                                   ecstat4
                                   details_known_5
                                   relat5
                                   age5_known
                                   age5
                                   sex5
                                   ecstat5
                                   details_known_6
                                   relat6
                                   age6_known
                                   age6
                                   sex6
                                   ecstat6
                                   details_known_7
                                   relat7
                                   age7_known
                                   age7
                                   sex7
                                   ecstat7
                                   details_known_8
                                   relat8
                                   age8_known
                                   age8
                                   sex8
                                   ecstat8
                                   armedforces
                                   leftreg
                                   reservist
                                   preg_occ
                                   housingneeds
                                   housingneeds_type
                                   housingneeds_other
                                   illness
                                   illness_type_4
                                   illness_type_5
                                   illness_type_2
                                   illness_type_6
                                   illness_type_7
                                   illness_type_3
                                   illness_type_9
                                   illness_type_8
                                   illness_type_1
                                   illness_type_10
                                   layear
                                   waityear
                                   reason
                                   reasonother
                                   prevten
                                   underoccupation_benefitcap
                                   homeless
                                   ppcodenk
                                   ppostcode_full
                                   previous_la_known
                                   is_previous_la_inferred
                                   prevloc_label
                                   prevloc
                                   reasonpref
                                   rp_homeless
                                   rp_insan_unsat
                                   rp_medwel
                                   rp_hardship
                                   rp_dontknow
                                   cbl
                                   cap
                                   chr
                                   letting_allocation_unknown
                                   referral
                                   net_income_known
                                   earnings
                                   incfreq
                                   net_income_value_check
                                   hb
                                   benefits
                                   household_charge
                                   period
                                   is_carehome
                                   chcharge
                                   brent
                                   scharge
                                   pscharge
                                   supcharg
                                   tcharge
                                   rent_value_check
                                   hbrentshortfall
                                   tshortfall_known
                                   tshortfall
                                   housingneeds_a
                                   housingneeds_b
                                   housingneeds_c
                                   housingneeds_f
                                   housingneeds_g
                                   housingneeds_h
                                   property_owner_organisation
                                   property_manager_organisation
                                   purchaser_code
                                   property_relet
                                   incref
                                   renttype
                                   lettype
                                   totchild
                                   totelder
                                   totadult
                                   nocharge
                                   has_benefits
                                   wrent
                                   wscharge
                                   wpschrge
                                   wsupchrg
                                   wtcharge
                                   wtshortfall
                                   refused
                                   wchchrg
                                   newprop
                                   old_form_id
                                   lar
                                   irproduct
                                   old_id
                                   joint
                                   hhtype
                                   new_old
                                   vacdays
                                   unresolved
                                   updated_by_id
                                   unittype_sh
                                   scheme_code
                                   scheme_service_name
                                   scheme_sensitive
                                   scheme_type
                                   scheme_registered_under_care_act
                                   scheme_owning_organisation_name
                                   scheme_primary_client_group
                                   scheme_has_other_client_group
                                   scheme_secondary_client_group
                                   scheme_support_type
                                   scheme_intended_stay
                                   scheme_created_at
                                   location_code
                                   location_postcode
                                   location_name
                                   location_units
                                   location_type_of_unit
                                   location_mobility_type
                                   location_admin_district
                                   location_startdate]
      csv = CSV.parse(described_class.new(user).to_csv)
      expect(csv.first).to eq(expected_csv_attributes)
    end
  end
end
