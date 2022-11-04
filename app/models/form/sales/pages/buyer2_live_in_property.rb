class Form::Sales::Pages::Buyer2LiveInProperty < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_live_in_property"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2LiveInProperty.new(nil, nil, self),
    ]
  end
end