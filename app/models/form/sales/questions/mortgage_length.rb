class Form::Sales::Questions::MortgageLength < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mortlen"
    @check_answer_label = "Length of mortgage"
    @header = "What is the length of the mortgage?"
    @type = "numeric"
    @min = 0
    @width = 5
    @suffix = " years"
  end
end