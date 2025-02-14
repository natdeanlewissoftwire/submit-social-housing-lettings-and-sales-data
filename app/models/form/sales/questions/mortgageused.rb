class Form::Sales::Questions::Mortgageused < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mortgageused"
    @check_answer_label = "Mortgage used"
    @header = "Was a mortgage used for the purchase of this property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  def displayed_answer_options(_log, _user = nil)
    {
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
    }
  end
end
