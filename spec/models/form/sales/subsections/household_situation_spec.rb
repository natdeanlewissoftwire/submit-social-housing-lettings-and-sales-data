require "rails_helper"

RSpec.describe Form::Sales::Subsections::HouseholdSituation, type: :model do
  subject(:household_characteristics) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Sales::Sections::Household) }

  it "has correct section" do
    expect(household_characteristics.section).to eq(section)
  end

  it "has correct pages" do
    expect(household_characteristics.pages.map(&:id)).to eq(
      %w[
        buyer1_previous_tenure
        last_accommodation
        last_accommodation_la
        buyers_organisations
      ],
    )
  end

  it "has the correct id" do
    expect(household_characteristics.id).to eq("household_situation")
  end

  it "has the correct label" do
    expect(household_characteristics.label).to eq("Household situation")
  end

  it "has correct depends on" do
    expect(household_characteristics.depends_on).to eq([{ "setup_completed?" => true }])
  end
end
