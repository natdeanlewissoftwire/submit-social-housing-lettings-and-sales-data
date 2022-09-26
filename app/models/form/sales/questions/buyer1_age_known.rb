class Form::Sales::Questions::Buyer1AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age1_known"
    @check_answer_label = "Buyer 1's age"
    @header = "Do you know buyer 1's age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = "Buyer 1 is the person in the household who does the most paid work. If it's a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest."
    @conditional_for = {
      "age1" => [0],
    }
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end