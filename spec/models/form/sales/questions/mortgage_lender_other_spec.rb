require "rails_helper"

RSpec.describe Form::Sales::Questions::MortgageLenderOther, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("mortgagelenderother")
  end

  it "has the correct header" do
    expect(question.header).to eq("What is the other mortgage lender?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Other Mortgage Lender")
  end

  it "has the correct type" do
    expect(question.type).to eq("text")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to be_nil
  end
end
