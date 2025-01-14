class Form::Sales::Subsections::PropertyInformation < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "property_information"
    @label = "Property information"
    @depends_on = [{ "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::PropertyNumberOfBedrooms.new(nil, nil, self),
      Form::Sales::Pages::AboutPriceValueCheck.new("about_price_bedrooms_value_check", nil, self),
      Form::Sales::Pages::PropertyUnitType.new(nil, nil, self),
      Form::Sales::Pages::MonthlyChargesValueCheck.new("monthly_charges_property_type_value_check", nil, self),
      Form::Sales::Pages::PropertyBuildingType.new(nil, nil, self),
      Form::Sales::Pages::Postcode.new(nil, nil, self),
      Form::Sales::Pages::PropertyLocalAuthority.new(nil, nil, self),
      Form::Sales::Pages::AboutPriceValueCheck.new("about_price_la_value_check", nil, self),
      Form::Sales::Pages::PropertyWheelchairAccessible.new(nil, nil, self),
    ]
  end
end
