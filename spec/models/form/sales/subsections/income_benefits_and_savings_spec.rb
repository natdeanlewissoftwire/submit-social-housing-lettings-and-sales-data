require "rails_helper"

RSpec.describe Form::Sales::Subsections::IncomeBenefitsAndSavings, type: :model do
  subject(:subsection) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Sales::Sections::Household) }

  it "has correct section" do
    expect(subsection.section).to eq(section)
  end

  describe "pages" do
    let(:section) { instance_double(Form::Sales::Sections::Household, form: instance_double(Form, start_date:)) }

    context "when 2022" do
      let(:start_date) { Time.utc(2022, 2, 8) }

      it "has correct pages" do
        expect(subsection.pages.compact.map(&:id)).to eq(
          %w[
            buyer_1_income
            buyer_1_income_value_check
            buyer_1_income_mortgage_value_check
            buyer_1_mortgage
            buyer_1_mortgage_value_check
            buyer_2_income
            buyer_2_income_mortgage_value_check
            buyer_2_income_value_check
            buyer_2_mortgage
            buyer_2_mortgage_value_check
            housing_benefits_joint_purchase
            housing_benefits_not_joint_purchase
            savings
            savings_value_check
            savings_deposit_value_check
            previous_ownership
          ],
        )
      end
    end

    context "when 2023" do
      let(:start_date) { Time.utc(2023, 2, 8) }

      it "has correct pages" do
        expect(subsection.pages.map(&:id)).to eq(
          %w[
            buyer_1_income
            buyer_1_income_value_check
            buyer_1_income_mortgage_value_check
            buyer_1_mortgage
            buyer_1_mortgage_value_check
            buyer_2_income
            buyer_2_income_mortgage_value_check
            buyer_2_income_value_check
            buyer_2_mortgage
            buyer_2_mortgage_value_check
            housing_benefits_joint_purchase
            housing_benefits_not_joint_purchase
            savings
            savings_value_check
            savings_deposit_value_check
            previous_ownership
            previous_shared
          ],
        )
      end
    end
  end

  it "has the correct id" do
    expect(subsection.id).to eq("income_benefits_and_savings")
  end

  it "has the correct label" do
    expect(subsection.label).to eq("Income, benefits and savings")
  end

  it "has correct depends on" do
    expect(subsection.depends_on).to eq([{ "setup_completed?" => true }])
  end
end
