class Form::Lettings::Pages::RentBiWeekly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_bi_weekly"
    @header = "Household rent and charges"
    @depends_on = [
      { "household_charge" => 0, "period" => 2, "is_carehome" => 0 },
      { "household_charge" => nil, "period" => 2, "is_carehome" => 0 },
      { "household_charge" => 0, "period" => 2, "is_carehome" => nil },
      { "household_charge" => nil, "period" => 2, "is_carehome" => nil },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::BrentBiWeekly.new(nil, nil, self),
      Form::Lettings::Questions::SchargeBiWeekly.new(nil, nil, self),
      Form::Lettings::Questions::PschargeBiWeekly.new(nil, nil, self),
      Form::Lettings::Questions::SupchargBiWeekly.new(nil, nil, self),
      Form::Lettings::Questions::TchargeBiWeekly.new(nil, nil, self),
    ]
  end
end
