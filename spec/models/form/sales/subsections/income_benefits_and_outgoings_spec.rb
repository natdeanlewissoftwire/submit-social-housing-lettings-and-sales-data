require "rails_helper"

RSpec.describe Form::Sales::Subsections::IncomeBenefitsAndOutgoings, type: :model do
  subject(:subsection) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Sales::Sections::Household) }

  it "has correct section" do
    expect(subsection.section).to eq(section)
  end

  it "has correct pages" do
    expect(subsection.pages.map(&:id)).to eq(
      %w[
        buyer_1_income
      ],
    )
  end

  it "has the correct id" do
    expect(subsection.id).to eq("income_benefits_and_outgoings")
  end

  it "has the correct label" do
    expect(subsection.label).to eq("Income, benefits and outgoings")
  end

  it "has correct depends on" do
    expect(subsection.depends_on).to eq([{ "setup" => "completed" }])
  end
end