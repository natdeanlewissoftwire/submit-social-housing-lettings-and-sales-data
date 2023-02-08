class Form::Lettings::Pages::PropertyUnitType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_unit_type"
    @depends_on = [{ "needstype" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::UnittypeGn.new(nil, nil, self)]
  end
end