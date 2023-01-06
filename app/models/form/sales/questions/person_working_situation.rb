class Form::Sales::Questions::PersonWorkingSituation < ::Form::Sales::Questions::Person
  def initialize(id, hsh, page, person_index:)
    super
    @check_answer_label = "Person #{person_display_number}’s working situation"
    @header = "Which of these best describes Person #{person_display_number}’s working situation?"
    @type = "radio"
    @page = page
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = person_index
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Part-time - Less than 30 hours" },
    "1" => { "value" => "Full-time - 30 hours or more" },
    "3" => { "value" => "In government training into work, such as New Deal" },
    "4" => { "value" => "Jobseeker" },
    "6" => { "value" => "Not seeking work" },
    "8" => { "value" => "Unable to work due to long term sick or disability" },
    "5" => { "value" => "Retired" },
    "0" => { "value" => "Other" },
    "10" => { "value" => "Person prefers not to say" },
    "7" => { "value" => "Full-time student" },
    "9" => { "value" => "Child under 16" },
  }.freeze
end