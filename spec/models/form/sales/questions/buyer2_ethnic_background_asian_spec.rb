require "rails_helper"

RSpec.describe Form::Sales::Questions::Buyer2EthnicBackgroundAsian, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("ethnicbuy2")
  end

  it "has the correct header" do
    expect(question.header).to eq("Which of the following best describes the buyer 2’s Asian or Asian British background?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Buyer 2’s ethnic background")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to be nil
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "10" => { "value" => "Bangladeshi" },
      "11" => { "value" => "Any other Asian or Asian British background" },
      "15" => { "value" => "Chinese" },
      "8" => { "value" => "Indian" },
      "9" => { "value" => "Pakistani" },
    })
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(2)
  end
end