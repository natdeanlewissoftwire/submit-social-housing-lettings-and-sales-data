require "rails_helper"

RSpec.describe Form::Sales::Questions::NumberOfOthersInProperty, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, joint_purchase:) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:joint_purchase) { true }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("hholdcount")
  end

  it "has the correct header" do
    expect(question.header).to eq("Besides the buyer(s), how many other people live or will live in the property?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Number of other people living in the property")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("You can provide details for a maximum of 4 other people for a joint purchase.")
  end

  it "has the correct min" do
    expect(question.min).to eq(0)
  end

  it "has the correct max" do
    expect(question.max).to eq(4)
  end

  context "with non joint purchase" do
    let(:joint_purchase) { false }

    it "has the correct hint" do
      expect(question.hint_text).to eq("You can provide details for a maximum of 5 other people if there is only one buyer.")
    end

    it "has the correct max" do
      expect(question.max).to eq(5)
    end
  end
end
