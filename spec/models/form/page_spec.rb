require "rails_helper"

RSpec.describe Form::Page, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:user) { FactoryBot.create(:user) }
  let(:lettings_log) { FactoryBot.build(:lettings_log) }
  let(:form) { lettings_log.form }
  let(:section_id) { "rent_and_charges" }
  let(:section_definition) { form.form_definition["sections"][section_id] }
  let(:section) { Form::Section.new(section_id, section_definition, form) }
  let(:subsection_id) { "income_and_benefits" }
  let(:subsection_definition) { section_definition["subsections"][subsection_id] }
  let(:subsection) { Form::Subsection.new(subsection_id, subsection_definition, section) }
  let(:page_id) { "net_income" }
  let(:page_definition) { subsection_definition["pages"][page_id] }
  let(:fake_2021_2022_form) { Form.new("spec/fixtures/forms/2021_2022.json") }

  before do
    allow(FormHandler.instance).to receive(:current_lettings_form).and_return(fake_2021_2022_form)
  end

  it "has an id" do
    expect(page.id).to eq(page_id)
  end

  it "has a header" do
    expect(page.header).to eq("Test header")
  end

  it "has a description" do
    expect(page.description).to eq("Some extra text for the page")
  end

  it "has questions" do
    expected_questions = %w[earnings incfreq]
    expect(page.questions.map(&:id)).to eq(expected_questions)
  end

  context "with a page having conditional questions" do
    let(:page_id) { "housing_benefit" }

    it "knows which questions are not conditional" do
      expected_non_conditional_questions = %w[hb]
      expect(page.non_conditional_questions.map(&:id))
        .to eq(expected_non_conditional_questions)
    end
  end

  describe "#interruption_screen?" do
    context "when it has regular questions" do
      it "returns false" do
        expect(page.interruption_screen?).to be false
      end
    end

    context "when it has interruption_screen question" do
      let(:page) { form.get_page("retirement_value_check") }

      it "returns true" do
        expect(page.interruption_screen?).to be true
      end
    end
  end

  context "with a lettings log" do
    let(:lettings_log) { FactoryBot.build(:lettings_log, :in_progress) }

    it "knows if it's been routed to" do
      expect(page.routed_to?(lettings_log, user)).to be true
    end

    context "with routing conditions" do
      let(:page_id) { "dependent_page" }

      it "evaluates not met conditions correctly" do
        expect(page.routed_to?(lettings_log, user)).to be false
      end

      it "evaluates met conditions correctly" do
        lettings_log.incfreq = 1
        expect(page.routed_to?(lettings_log, user)).to be true
      end
    end

    context "with expression routing conditions" do
      let(:section_id) { "household" }
      let(:subsection_id) { "household_characteristics" }
      let(:page_id) { "person_2_working_situation" }

      it "evaluates not met conditions correctly" do
        lettings_log.age2 = 12
        expect(page.routed_to?(lettings_log, user)).to be false
      end

      it "evaluates met conditions correctly" do
        lettings_log.age2 = 17
        expect(page.routed_to?(lettings_log, user)).to be true
      end
    end

    context "when the page's subsection has routing conditions" do
      let(:section_id) { "submission" }
      let(:subsection_id) { "declaration" }
      let(:page_id) { "declaration" }
      let(:completed_lettings_log) { FactoryBot.build(:lettings_log, :completed, incfreq: "Weekly") }

      it "evaluates the sections dependencies" do
        expect(page.routed_to?(lettings_log, user)).to be false
        expect(page.routed_to?(completed_lettings_log, user)).to be true
      end
    end
  end
end
