class Form::Sales::Pages::HouseholdDisability < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "household_disability"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HouseholdDisability.new(nil, nil, self),
    ]
  end
end