require "rails_helper"

RSpec.describe Form::Sales::Questions::HousingBenefits, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, joint_purchase:) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:joint_purchase) { false }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("hb")
  end

  context "when joint purchase is false" do
    it "has the correct header" do
      expect(question.header).to eq("Was the buyer receiving any of these housing-related benefits immediately before buying this property?")
    end
  end

  context "when joint purchase is true" do
    let(:joint_purchase) { true }

    it "has the correct header" do
      expect(question.header).to eq("Were the buyers receiving any of these housing-related benefits immediately before buying this property?")
    end
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Housing-related benefits buyer received before buying this property")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to be_nil
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "2" => { "value" => "Housing benefit" },
      "3" => { "value" => "Universal Credit housing element" },
      "divider" => { "value" => true },
      "1" => { "value" => "Neither housing benefit or Universal Credit housing element" },
      "4" => { "value" => "Don’t know " },
    })
  end
end
