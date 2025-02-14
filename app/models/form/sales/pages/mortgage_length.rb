class Form::Sales::Pages::MortgageLength < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [{
      "mortgageused" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageLength.new(nil, nil, self),
    ]
  end
end
