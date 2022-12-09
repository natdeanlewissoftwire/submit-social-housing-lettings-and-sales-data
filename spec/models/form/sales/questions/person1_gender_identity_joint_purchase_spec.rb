require "rails_helper"

RSpec.describe Form::Sales::Questions::Person1GenderIdentityJointPurchase, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("sex3")
  end

  it "has the correct header" do
    expect(question.header).to eq("Which of these best describes Person 1’s gender identity?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Person 1’s gender identity")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has expected check answers card number" do
    expect(question.check_answers_card_number).to eq(3)
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "F" => { "value" => "Female" },
      "M" => { "value" => "Male" },
      "X" => { "value" => "Non-binary" },
      "R" => { "value" => "Buyer prefers not to say" },
    })
  end
end