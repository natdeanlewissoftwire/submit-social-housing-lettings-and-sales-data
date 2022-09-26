class Form::Sales::Pages::SaleDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "completion_date"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::SaleDate.new(nil, nil, self),
    ]
  end
end