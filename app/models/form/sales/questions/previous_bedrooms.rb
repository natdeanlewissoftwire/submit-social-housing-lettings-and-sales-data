class Form::Sales::Questions::PreviousBedrooms < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "frombeds"
    @check_answer_label = "Number of bedrooms in previous property"
    @header = "How many bedrooms did the property have?"
    @type = "numeric"
    @page = page
    @width = 5
    @min = 0
    @hint_text = "For bedsits enter 1"
  end
end