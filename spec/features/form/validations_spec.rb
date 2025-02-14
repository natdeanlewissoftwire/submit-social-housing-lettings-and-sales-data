require "rails_helper"
require_relative "helpers"

RSpec.describe "validations" do
  let(:fake_2021_2022_form) { Form.new("spec/fixtures/forms/2021_2022.json") }
  let(:user) { FactoryBot.create(:user) }
  let(:lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :in_progress,
      created_by: user,
      renewal: 0,
    )
  end
  let(:empty_lettings_log) do
    FactoryBot.create(
      :lettings_log,
      created_by: user,
    )
  end
  let(:completed_without_declaration) do
    FactoryBot.create(
      :lettings_log,
      :completed,
      created_by: user,
      status: 1,
      declaration: nil,
      startdate: Time.zone.local(2021, 5, 1),
    )
  end
  let(:id) { lettings_log.id }

  before do
    allow(fake_2021_2022_form).to receive(:end_date).and_return(Time.zone.today + 1.day)
    allow(lettings_log.form).to receive(:end_date).and_return(Time.zone.today + 1.day)
    sign_in user
    allow(FormHandler.instance).to receive(:current_lettings_form).and_return(fake_2021_2022_form)
  end

  include Helpers

  describe "Question validation" do
    context "when the tenant age is invalid" do
      it "shows validation for under 0" do
        visit("/lettings-logs/#{id}/person-1-age")
        fill_in_number_question(empty_lettings_log.id, "age1", -5, "person-1-age")
        expect(page).to have_selector("#error-summary-title")
        expect(page).to have_selector("#lettings-log-age1-error")
        expect(page).to have_selector("#lettings-log-age1-field-error")
        expect(page).to have_title("Error")
      end

      it "shows validation for over 120" do
        visit("/lettings-logs/#{id}/person-1-age")
        fill_in_number_question(empty_lettings_log.id, "age1", 121, "person-1-age")
        expect(page).to have_selector("#error-summary-title")
        expect(page).to have_selector("#lettings-log-age1-error")
        expect(page).to have_selector("#lettings-log-age1-field-error")
        expect(page).to have_title("Error")
      end
    end
  end

  describe "date validation", js: true do
    def fill_in_date(lettings_log_id, question, day, month, year, path)
      visit("/lettings-logs/#{lettings_log_id}/#{path}")
      fill_in("lettings_log[#{question}(1i)]", with: year)
      fill_in("lettings_log[#{question}(2i)]", with: month)
      fill_in("lettings_log[#{question}(3i)]", with: day)
    end

    it "does not allow out of range dates to be submitted" do
      fill_in_date(id, "mrcdate", 3100, 12, 2000, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")

      fill_in_date(id, "mrcdate", 12, 1, 20_000, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")

      fill_in_date(id, "mrcdate", 13, 100, 2020, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")

      fill_in_date(id, "mrcdate", 21, 11, 2020, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/local-authority/check-answers")
    end

    it "does not allow non numeric inputs to be submitted" do
      fill_in_date(id, "mrcdate", "abc", "de", "ff", "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")
    end

    it "does not allow partial inputs to be submitted" do
      fill_in_date(id, "mrcdate", 21, 12, nil, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")

      fill_in_date(id, "mrcdate", 12, nil, 2000, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")

      fill_in_date(id, "mrcdate", nil, 10, 2020, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")
    end

    it "allows valid inputs to be submitted" do
      fill_in_date(id, "mrcdate", 21, 11, 2020, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/local-authority/check-answers")
    end
  end

  describe "Soft Validation" do
    context "when a weekly net income is above the expected amount for the given economic status but below the hard max" do
      let(:lettings_log) do
        FactoryBot.create(
          :lettings_log,
          :in_progress,
          ecstat1: 1,
          created_by: user,
        )
      end
      let(:income_over_soft_limit) { 750 }
      let(:income_under_soft_limit) { 700 }

      it "prompts the user to confirm the value is correct with an interruption screen" do
        visit("/lettings-logs/#{lettings_log.id}/net-income")
        fill_in("lettings-log-earnings-field", with: income_over_soft_limit)
        choose("lettings-log-incfreq-1-field", allow_label_click: true)
        click_button("Save and continue")
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/net-income-value-check")
        expect(page).to have_content("Net income is outside the expected range based on the lead tenant’s working situation")
        expect(page).to have_content("You told us the lead tenant’s working situation is: full-time – 30 hours or more")
        expect(page).to have_content("The household income you have entered is £750.00 every week")
        choose("lettings-log-net-income-value-check-0-field", allow_label_click: true)
        click_button("Save and continue")
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/net-income-uc-proportion")
      end

      it "returns the user to the previous question if they do not confirm the value as correct on the interruption screen" do
        visit("/lettings-logs/#{lettings_log.id}/net-income")
        fill_in("lettings-log-earnings-field", with: income_over_soft_limit)
        choose("lettings-log-incfreq-1-field", allow_label_click: true)
        click_button("Save and continue")
        choose("lettings-log-net-income-value-check-1-field", allow_label_click: true)
        click_button("Save and continue")
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/net-income")
      end
    end
  end

  describe "Submission validation" do
    context "when tenant has not seen the privacy notice" do
      it "shows a warning" do
        visit("/lettings-logs/#{completed_without_declaration.id}/declaration")
        click_button("Save and continue")
        expect(page).to have_content("You must show the DLUHC privacy notice to the tenant")
      end
    end
  end
end
