FactoryBot.define do
  factory :lettings_log do
    created_by { FactoryBot.create(:user) }
    owning_organisation { created_by.organisation }
    managing_organisation { created_by.organisation }
    trait :about_completed do
      renewal { 0 }
      needstype { 1 }
      rent_type { 1 }
      startdate { Time.zone.local(2022, 5, 1) }
    end
    trait :in_progress do
      status { 1 }
      tenancycode { Faker::Name.initials(number: 10) }
      postcode_full { Faker::Address.postcode }
      ppostcode_full { Faker::Address.postcode }
      age1 { 17 }
      age2 { 19 }
      renewal { 1 }
      rent_type { 1 }
      startdate { Time.zone.local(2021, 5, 1) }
    end
    trait :soft_validations_triggered do
      status { 1 }
      ecstat1 { 1 }
      earnings { 750 }
      incfreq { 1 }
    end
    trait :conditional_section_complete do
      tenancycode { Faker::Name.initials(number: 10) }
      age1 { 34 }
      sex1 { "M" }
      ethnic { 2 }
      national { 4 }
      ecstat1 { 2 }
      hhmemb { 1 }
    end
    trait :completed do
      status { 2 }
      tenancycode { Faker::Name.initials(number: 10) }
      age1_known { 0 }
      age1 { 35 }
      sex1 { "F" }
      ethnic_group { 0 }
      ethnic { 2 }
      national { 4 }
      prevten { 6 }
      ecstat1 { 0 }
      hhmemb { 2 }
      relat2 { "P" }
      age2_known { 0 }
      details_known_2 { 0 }
      age2 { 32 }
      sex2 { "M" }
      ecstat2 { 6 }
      homeless { 1 }
      underoccupation_benefitcap { 0 }
      leftreg { 1 }
      reservist { 1 }
      illness { 1 }
      preg_occ { 2 }
      startertenancy { 1 }
      tenancylength { nil }
      tenancy { 1 }
      ppostcode_full { Faker::Address.postcode }
      rsnvac { 6 }
      unittype_gn { 7 }
      beds { 3 }
      voiddate { "03/11/2019" }
      offered { 2 }
      wchair { 1 }
      earnings { 68 }
      incfreq { 1 }
      benefits { 1 }
      period { 2 }
      brent { 200 }
      scharge { 50 }
      pscharge { 40 }
      supcharg { 35 }
      tcharge { 325 }
      layear { 2 }
      waityear { 1 }
      postcode_known { 1 }
      postcode_full { Faker::Address.postcode }
      reasonpref { 1 }
      cbl { 0 }
      chr { 1 }
      cap { 0 }
      reasonother { nil }
      housingneeds { 1 }
      housingneeds_type { 0 }
      housingneeds_other { 0 }
      housingneeds_a { 1 }
      housingneeds_b { 0 }
      housingneeds_c { 0 }
      housingneeds_f { 0 }
      housingneeds_g { 0 }
      housingneeds_h { 0 }
      illness_type_1 { 0 }
      illness_type_2 { 1 }
      illness_type_3 { 0 }
      illness_type_4 { 0 }
      illness_type_8 { 0 }
      illness_type_5 { 0 }
      illness_type_6 { 0 }
      illness_type_7 { 0 }
      illness_type_9 { 0 }
      illness_type_10 { 0 }
      rp_homeless { 0 }
      rp_insan_unsat { 1 }
      rp_medwel { 0 }
      rp_hardship { 0 }
      rp_dontknow { 0 }
      tenancyother { nil }
      net_income_value_check { nil }
      void_date_value_check { 1 }
      major_repairs_date_value_check { 1 }
      net_income_known { 0 }
      previous_la_known { 1 }
      property_owner_organisation { "Test" }
      property_manager_organisation { "Test" }
      renewal { 0 }
      rent_type { 1 }
      needstype { 1 }
      purchaser_code { 798_794 }
      reason { 4 }
      propcode { Faker::Name.initials(number: 10) }
      majorrepairs { 1 }
      la { "E09000003" }
      prevloc { "E07000105" }
      hb { 6 }
      hbrentshortfall { 1 }
      tshortfall { 12 }
      property_relet { 0 }
      mrcdate { Time.zone.local(2020, 5, 5, 10, 36, 49) }
      incref { 0 }
      startdate { Time.zone.today }
      armedforces { 1 }
      builtype { 1 }
      unitletas { 2 }
      has_benefits { 1 }
      is_carehome { 0 }
      declaration { 1 }
      first_time_property_let_as_social_housing { 0 }
      referral { 2 }
    end
    trait :export do
      tenancycode { "987654" }
      ppostcode_full { "LE5 1QP" }
      propcode { "MYPROP" }
      tenancylength { nil }
    end
    trait :sh do
      needstype { 2 }
      sheltered { 0 }
      household_charge { 0 }
    end
    created_at { Time.utc(2022, 2, 8, 16, 52, 15) }
    updated_at { Time.utc(2022, 2, 8, 16, 52, 15) }
  end
end
