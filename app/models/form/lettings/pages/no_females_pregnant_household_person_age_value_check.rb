class Form::Lettings::Pages::NoFemalesPregnantHouseholdPersonAgeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "no_females_pregnant_household_person_#{person_index}_age_value_check"
    @depends_on = [{ "no_females_in_a_pregnant_household?" => true, "age#{person_index}_known" => 0 }]
    @title_text = {
      "translation" => "soft_validations.pregnancy.title",
      "arguments" => [{ "key" => "sex1", "label" => true, "i18n_template" => "sex1" }],
    }
    @informative_text = {
      "translation" => "soft_validations.pregnancy.no_females",
      "arguments" => [{ "key" => "sex1", "label" => true, "i18n_template" => "sex1" }],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PregnancyValueCheck.new(nil, nil, self)]
  end
end