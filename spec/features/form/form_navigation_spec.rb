require "rails_helper"
require_relative "helpers"

RSpec.describe "Form Navigation" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :in_progress,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      created_by: user,
    )
  end
  let(:empty_lettings_log) do
    FactoryBot.create(
      :lettings_log,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      created_by: user,
    )
  end

  let(:id) { lettings_log.id }
  let(:question_answers) do
    {
      tenancycode: { type: "text", answer: "BZ737", path: "tenant-code-test" },
      age1: { type: "numeric", answer: 25, path: "person-1-age" },
      sex1: { type: "radio", answer: "Female", path: "person-1-gender" },
      ecstat1: { type: "radio", answer: 3, path: "person-1-working-situation" },
      hhmemb: { type: "numeric", answer: 1, path: "household-number-of-members" },
    }
  end
  let(:fake_2021_2022_form) { Form.new("spec/fixtures/forms/2021_2022.json") }

  before do
    allow(lettings_log.form).to receive(:end_date).and_return(Time.zone.today + 1.day)
    allow(fake_2021_2022_form).to receive(:end_date).and_return(Time.zone.today + 1.day)
    sign_in user
    allow(FormHandler.instance).to receive(:current_lettings_form).and_return(fake_2021_2022_form)
  end

  describe "Create a new lettings log" do
    it "redirects to the task list for the new log" do
      visit("/lettings-logs")
      click_button("Create a new lettings log")
      id = LettingsLog.order(created_at: :desc).first.id
      expect(page).to have_content("Log #{id}")
    end
  end

  describe "Viewing a log" do
    it "questions can be accessed by url" do
      visit("/lettings-logs/#{id}/person-1-age")
      expect(page).to have_field("lettings-log-age1-field")
    end

    it "a question page leads to the next question defined in the form definition" do
      pages = question_answers.map { |_key, val| val[:path] }
      pages[0..-2].each_with_index do |val, index|
        visit("/lettings-logs/#{id}/#{val}")
        click_link("Skip for now")
        expect(page).to have_current_path("/lettings-logs/#{id}/#{pages[index + 1]}")
      end
    end

    it "a question page has a Skip for now link that lets you move on to the next question without inputting anything" do
      visit("/lettings-logs/#{empty_lettings_log.id}/tenant-code-test")
      click_link(text: "Skip for now")
      expect(page).to have_current_path("/lettings-logs/#{empty_lettings_log.id}/person-1-age")
    end

    it "routes to check answers when skipping on the last page in the form" do
      visit("/lettings-logs/#{empty_lettings_log.id}/propcode")
      click_link(text: "Skip for now")
      expect(page).to have_current_path("/lettings-logs/#{empty_lettings_log.id}/household-characteristics/check-answers")
    end

    describe "Back link directs correctly", js: true do
      it "go back to tasklist page from tenant code" do
        visit("/lettings-logs/#{id}")
        visit("/lettings-logs/#{id}/tenant-code-test")
        click_link(text: "Back")
        expect(page).to have_content("Log #{id}")
      end

      it "go back to tenant code page from tenant age page", js: true do
        visit("/lettings-logs/#{id}/tenant-code-test")
        click_button("Save and continue")
        visit("/lettings-logs/#{id}/person-1-age")
        click_link(text: "Back")
        expect(page).to have_field("lettings-log-tenancycode-field")
      end

      it "doesn't get stuck in infinite loops", js: true do
        visit("/lettings-logs")
        visit("/lettings-logs/#{id}/net-income")
        fill_in("lettings-log-earnings-field", with: 740)
        choose("lettings-log-incfreq-1-field", allow_label_click: true)
        click_button("Save and continue")
        click_link(text: "Back")
        click_link(text: "Back")
        expect(page).to have_current_path("/lettings-logs")
      end

      context "when changing an answer from the check answers page", js: true do
        it "the back button routes correctly" do
          visit("/lettings-logs/#{id}/household-characteristics/check-answers")
          first("a", text: /Answer/).click
          click_link("Back")
          expect(page).to have_current_path("/lettings-logs/#{id}/household-characteristics/check-answers")
        end
      end
    end
  end

  describe "Editing a log" do
    it "a question page has a link allowing you to cancel your input and return to the check answers page" do
      visit("lettings-logs/#{id}/tenant-code-test?referrer=check_answers")
      click_link(text: "Cancel")
      expect(page).to have_current_path("/lettings-logs/#{id}/household-characteristics/check-answers")
    end

    context "when clicking save and continue on a mandatory question with no input" do
      let(:id) { empty_lettings_log.id }

      it "shows a validation error on radio questions" do
        visit("/lettings-logs/#{id}/renewal")
        click_button("Save and continue")
        expect(page).to have_selector("#error-summary-title")
        expect(page).to have_selector("#lettings-log-renewal-error")
        expect(page).to have_title("Error")
      end

      it "shows a validation error on date questions" do
        visit("/lettings-logs/#{id}/tenancy-start-date")
        click_button("Save and continue")
        expect(page).to have_selector("#error-summary-title")
        expect(page).to have_selector("#lettings-log-startdate-error")
        expect(page).to have_title("Error")
      end

      context "when the page has a main and conditional question" do
        context "when the conditional question is required but not answered" do
          it "shows a validation error for the conditional question" do
            visit("/lettings-logs/#{id}/armed-forces")
            choose("lettings-log-armedforces-1-field", allow_label_click: true)
            click_button("Save and continue")
            expect(page).to have_selector("#error-summary-title")
            expect(page).to have_selector("#lettings-log-leftreg-error")
            expect(page).to have_title("Error")
          end
        end
      end
    end

    context "when clicking save and continue on an optional question with no input" do
      let(:id) { empty_lettings_log.id }

      it "does not show a validation error" do
        visit("/lettings-logs/#{id}/tenant-code")
        click_button("Save and continue")
        expect(page).not_to have_selector("#error-summary-title")
        expect(page).not_to have_title("Error")
        expect(page).to have_current_path("/lettings-logs/#{id}/property-reference")
      end
    end
  end
end
