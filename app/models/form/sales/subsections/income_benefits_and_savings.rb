class Form::Sales::Subsections::IncomeBenefitsAndSavings < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "income_benefits_and_savings"
    @label = "Income, benefits and savings"
    @section = section
    @depends_on = [{ "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::Buyer1Income.new(nil, nil, self),
      Form::Sales::Pages::Buyer1IncomeValueCheck.new("buyer_1_income_value_check", nil, self),
      Form::Sales::Pages::MortgageValueCheck.new("buyer_1_income_mortgage_value_check", nil, self),
      Form::Sales::Pages::Buyer1Mortgage.new(nil, nil, self),
      Form::Sales::Pages::MortgageValueCheck.new("buyer_1_mortgage_value_check", nil, self),
      Form::Sales::Pages::Buyer2Income.new(nil, nil, self),
      Form::Sales::Pages::MortgageValueCheck.new("buyer_2_income_mortgage_value_check", nil, self),
      Form::Sales::Pages::Savings.new(nil, nil, self),
      Form::Sales::Pages::PreviousOwnership.new(nil, nil, self),
    ]
  end
end
