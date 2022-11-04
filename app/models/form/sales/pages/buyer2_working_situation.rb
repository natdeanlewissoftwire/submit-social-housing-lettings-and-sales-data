class Form::Sales::Pages::Buyer2WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_working_situation"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2WorkingSituation.new(nil, nil, self),
    ]
  end
end