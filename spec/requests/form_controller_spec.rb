require "rails_helper"

RSpec.describe FormController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { create(:user) }
  let(:organisation) { user.organisation }
  let(:other_user) { create(:user) }
  let(:other_organisation) { other_user.organisation }
  let!(:unauthorized_lettings_log) do
    create(
      :lettings_log,
      created_by: other_user,
    )
  end
  let(:setup_complete_lettings_log) do
    create(
      :lettings_log,
      :about_completed,
      status: 1,
      startdate: Time.zone.local(2021, 10, 10),
      created_by: user,
    )
  end
  let(:completed_lettings_log) do
    create(
      :lettings_log,
      :completed,
      created_by: user,
      startdate: Time.zone.local(2021, 5, 1),
    )
  end
  let(:headers) { { "Accept" => "text/html" } }
  let(:fake_2021_2022_form) { Form.new("spec/fixtures/forms/2021_2022.json") }

  before do
    allow(fake_2021_2022_form).to receive(:end_date).and_return(Time.zone.today + 1.day)
    allow(FormHandler.instance).to receive(:current_lettings_form).and_return(fake_2021_2022_form)
  end

  context "when a user is not signed in" do
    let!(:lettings_log) do
      create(
        :lettings_log,
        created_by: user,
      )
    end

    describe "GET" do
      it "does not let you get lettings logs pages you don't have access to" do
        get "/lettings-logs/#{lettings_log.id}/person-1-age", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end

      it "does not let you get lettings log check answer pages you don't have access to" do
        get "/lettings-logs/#{lettings_log.id}/household-characteristics/check-answers", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "POST" do
      it "does not let you post form answers to lettings logs you don't have access to" do
        post "/lettings-logs/#{lettings_log.id}/form", params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end
  end

  context "when signed in as a support user" do
    let!(:lettings_log) do
      create(
        :lettings_log,
        created_by: user,
      )
    end
    let(:page) { Capybara::Node::Simple.new(response.body) }
    let(:managing_organisation) { create(:organisation) }
    let(:managing_organisation_too) { create(:organisation) }
    let(:stock_owner) { create(:organisation) }
    let(:support_user) { create(:user, :support) }

    before do
      organisation.stock_owners << stock_owner
      organisation.managing_agents << managing_organisation
      organisation.managing_agents << managing_organisation_too
      organisation.reload
      allow(support_user).to receive(:need_two_factor_authentication?).and_return(false)
      sign_in support_user
    end

    context "with invalid organisation answers" do
      let(:params) do
        {
          id: lettings_log.id,
          lettings_log: {
            page: "managing_organisation",
            managing_organisation_id: other_organisation.id,
          },
        }
      end

      before do
        lettings_log.update!(owning_organisation: stock_owner, created_by: user, managing_organisation: organisation)
        lettings_log.reload
      end

      it "resets created by and renders the next page" do
        post "/lettings-logs/#{lettings_log.id}/form", params: params
        expect(response).to redirect_to("/lettings-logs/#{lettings_log.id}/created-by")
        follow_redirect!
        lettings_log.reload
        expect(lettings_log.created_by).to eq(nil)
      end
    end

    context "with valid owning organisation" do
      let(:params) do
        {
          id: lettings_log.id,
          lettings_log: {
            page: "managing_organisation",
            managing_organisation_id: other_organisation.id,
          },
        }
      end

      before do
        lettings_log.update!(owning_organisation: organisation, created_by: user, managing_organisation: organisation)
        lettings_log.reload
      end

      it "does not reset created by" do
        post "/lettings-logs/#{lettings_log.id}/form", params: params
        expect(response).to redirect_to("/lettings-logs/#{lettings_log.id}/created-by")
        follow_redirect!
        lettings_log.reload
        expect(lettings_log.created_by).to eq(user)
      end
    end

    context "with valid managing organisation" do
      let(:params) do
        {
          id: lettings_log.id,
          lettings_log: {
            page: "stock_owner",
            owning_organisation_id: stock_owner.id,
          },
        }
      end

      before do
        lettings_log.update!(owning_organisation: organisation, created_by: user, managing_organisation: organisation)
        lettings_log.reload
      end

      it "does not reset created by" do
        post "/lettings-logs/#{lettings_log.id}/form", params: params
        expect(response).to redirect_to("/lettings-logs/#{lettings_log.id}/managing-organisation")
        follow_redirect!
        lettings_log.reload
        expect(lettings_log.created_by).to eq(user)
      end
    end

    context "with only adding the stock owner" do
      let(:params) do
        {
          id: lettings_log.id,
          lettings_log: {
            page: "stock_owner",
            owning_organisation_id: stock_owner.id,
          },
        }
      end

      before do
        lettings_log.update!(owning_organisation: nil, created_by: user, managing_organisation: nil)
        lettings_log.reload
      end

      it "does not reset created by" do
        post "/lettings-logs/#{lettings_log.id}/form", params: params
        expect(response).to redirect_to("/lettings-logs/#{lettings_log.id}/managing-organisation")
        follow_redirect!
        lettings_log.reload
        expect(lettings_log.created_by).to eq(user)
      end
    end
  end

  context "when a user is signed in" do
    let!(:lettings_log) do
      create(
        :lettings_log,
        created_by: user,
      )
    end

    before do
      allow(user).to receive(:need_two_factor_authentication?).and_return(false)
      sign_in user
    end

    describe "GET" do
      context "with form pages" do
        context "when forms exist for multiple years" do
          let(:lettings_log_year_1) { create(:lettings_log, startdate: Time.zone.local(2021, 5, 1), owning_organisation: organisation, created_by: user) }
          let(:lettings_log_year_2) { create(:lettings_log, :about_completed, startdate: Time.zone.local(2022, 5, 1), owning_organisation: organisation, created_by: user) }

          before do
            allow(lettings_log_year_1.form).to receive(:end_date).and_return(Time.zone.today + 1.day)
          end

          it "displays the correct question details for each lettings log based on form year" do
            get "/lettings-logs/#{lettings_log_year_1.id}/tenant-code-test", headers: headers, params: {}
            expect(response.body).to include("What is the tenant code?")
            get "/lettings-logs/#{lettings_log_year_2.id}/tenant-code-test", headers: headers, params: {}
            expect(response.body).to match("Different question header text for this year - 2023")
          end
        end

        context "when lettings logs are not owned or managed by your organisation" do
          it "does not show form pages for lettings logs you don't have access to" do
            get "/lettings-logs/#{unauthorized_lettings_log.id}/person-1-age", headers: headers, params: {}
            expect(response).to have_http_status(:not_found)
          end
        end

        context "with a form page that has custom guidance" do
          it "displays the correct partial" do
            get "/lettings-logs/#{lettings_log.id}/net-income", headers: headers, params: {}
            expect(response.body).to match("What counts as income?")
          end
        end

        context "when viewing the setup section schemes page" do
          context "when the user is support" do
            let(:user) { create(:user, :support) }

            context "when organisation and user have not been selected yet" do
              let(:lettings_log) do
                create(
                  :lettings_log,
                  owning_organisation: nil,
                  managing_organisation: nil,
                  created_by: nil,
                  needstype: 2,
                )
              end

              before do
                locations = create_list(:location, 5)
                locations.each { |location| location.scheme.update!(arrangement_type: "The same organisation that owns the housing stock") }
              end

              it "returns an unfiltered list of schemes" do
                get "/lettings-logs/#{lettings_log.id}/scheme", headers: headers, params: {}
                expect(response.body.scan("<option value=").count).to eq(6)
              end
            end
          end
        end
      end

      context "when displaying check answers pages" do
        context "when lettings logs are not owned or managed by your organisation" do
          it "does not show a check answers for lettings logs you don't have access to" do
            get "/lettings-logs/#{unauthorized_lettings_log.id}/household-characteristics/check-answers", headers: headers, params: {}
            expect(response).to have_http_status(:not_found)
          end
        end

        context "when no other sections are enabled" do
          let(:lettings_log_2022) do
            create(
              :lettings_log,
              startdate: Time.zone.local(2022, 12, 1),
              created_by: user,
            )
          end
          let(:headers) { { "Accept" => "text/html" } }

          before do
            Timecop.freeze(Time.zone.local(2022, 12, 1))
            get "/lettings-logs/#{lettings_log_2022.id}/setup/check-answers", headers:, params: {}
          end

          after do
            Timecop.unfreeze
          end

          it "does not show Save and go to next incomplete section button" do
            expect(page).not_to have_content("Save and go to next incomplete section")
          end
        end
      end

      context "with a question in a section that isn't enabled yet" do
        it "routes back to the tasklist page" do
          get "/lettings-logs/#{lettings_log.id}/declaration", headers: headers, params: {}
          expect(response).to redirect_to("/lettings-logs/#{lettings_log.id}")
        end
      end

      context "with a question that isn't enabled yet" do
        it "routes back to the tasklist page" do
          get "/lettings-logs/#{lettings_log.id}/conditional-question-no-second-page", headers: headers, params: {}
          expect(response).to redirect_to("/lettings-logs/#{lettings_log.id}")
        end
      end

      context "when visiting the review page" do
        it "renders the review page for the lettings log" do
          get "/lettings-logs/#{setup_complete_lettings_log.id}/review", headers: headers, params: {}
          expect(response.body).to match("Review lettings log")
        end

        it "renders the review page for the sales log" do
          log = create(:sales_log, :completed, created_by: user)
          get "/sales-logs/#{log.id}/review", headers: headers, params: { sales_log: true }
          expect(response.body).to match("Review sales log")
        end
      end

      context "when viewing a user dependent page" do
        context "when the dependency is met" do
          let(:user) { create(:user, :support) }

          it "routes to the page" do
            get "/lettings-logs/#{lettings_log.id}/created-by"
            expect(response).to have_http_status(:ok)
          end
        end

        context "when the dependency is not met" do
          it "redirects to the tasklist page" do
            get "/lettings-logs/#{lettings_log.id}/created-by"
            expect(response).to redirect_to("/lettings-logs/#{lettings_log.id}")
          end
        end
      end
    end

    describe "Submit Form" do
      context "with a form page" do
        let(:user) { create(:user) }
        let(:support_user) { FactoryBot.create(:user, :support) }
        let(:organisation) { user.organisation }
        let(:lettings_log) do
          create(
            :lettings_log,
            created_by: user,
          )
        end
        let(:page_id) { "person_1_age" }
        let(:params) do
          {
            id: lettings_log.id,
            lettings_log: {
              page: page_id,
              age1: answer,
            },
          }
        end
        let(:valid_params) do
          {
            id: lettings_log.id,
            lettings_log: {
              page: page_id,
              age1: valid_answer,
            },
          }
        end

        context "with invalid answers" do
          let(:page) { Capybara::Node::Simple.new(response.body) }
          let(:answer) { 2000 }
          let(:valid_answer) { 20 }

          before do
            allow(Rails.logger).to receive(:info)
          end

          it "re-renders the same page with errors if validation fails" do
            post "/lettings-logs/#{lettings_log.id}/form", params: params
            expect(response).to redirect_to("/lettings-logs/#{lettings_log.id}/#{page_id.dasherize}")
            follow_redirect!
            expect(page).to have_content("There is a problem")
          end

          it "resets errors when fixed" do
            post "/lettings-logs/#{lettings_log.id}/form", params: params
            post "/lettings-logs/#{lettings_log.id}/form", params: valid_params
            get "/lettings-logs/#{lettings_log.id}/#{page_id.dasherize}"
            expect(page).not_to have_content("There is a problem")
          end

          it "logs that validation was triggered" do
            expect(Rails.logger).to receive(:info).with("User triggered validation(s) on: age1").once
            post "/lettings-logs/#{lettings_log.id}/form", params:
          end

          context "when the number of days is too high for the month" do
            let(:page_id) { "tenancy_start_date" }
            let(:params) do
              {
                id: lettings_log.id,
                lettings_log: {
                  page: page_id,
                  "startdate(3i)" => 31,
                  "startdate(2i)" => 6,
                  "startdate(1i)" => 2022,
                },
              }
            end

            it "validates the date correctly" do
              post "/lettings-logs/#{lettings_log.id}/form", params: params
              follow_redirect!
              expect(page).to have_content("There is a problem")
            end
          end
        end

        context "with invalid organisation answers" do
          let(:page) { Capybara::Node::Simple.new(response.body) }
          let(:managing_organisation) { create(:organisation) }
          let(:managing_organisation_too) { create(:organisation) }
          let(:stock_owner) { create(:organisation) }
          let(:params) do
            {
              id: lettings_log.id,
              lettings_log: {
                page: "managing_organisation",
                managing_organisation_id: other_organisation.id,
              },
            }
          end

          before do
            organisation.stock_owners << stock_owner
            organisation.managing_agents << managing_organisation
            organisation.managing_agents << managing_organisation_too
            organisation.reload
            lettings_log.update!(owning_organisation: stock_owner, created_by: user, managing_organisation: organisation)
            lettings_log.reload
          end

          it "re-renders the same page with errors if validation fails" do
            post "/lettings-logs/#{lettings_log.id}/form", params: params
            expect(response).to redirect_to("/lettings-logs/#{lettings_log.id}/managing-organisation")
            follow_redirect!
            expect(page).to have_content("There is a problem")
          end
        end

        context "with valid answers" do
          let(:answer) { 20 }
          let(:params) do
            {
              id: lettings_log.id,
              lettings_log: {
                page: page_id,
                age1: answer,
                age2: 2000,
              },
            }
          end

          before do
            post "/lettings-logs/#{lettings_log.id}/form", params:
          end

          it "re-renders the same page with errors if validation fails" do
            expect(response).to have_http_status(:redirect)
          end

          it "only updates answers that apply to the page being submitted" do
            lettings_log.reload
            expect(lettings_log.age1).to eq(answer)
            expect(lettings_log.age2).to be nil
          end

          it "tracks who updated the record" do
            lettings_log.reload
            whodunnit_actor = lettings_log.versions.last.actor
            expect(whodunnit_actor).to be_a(User)
            expect(whodunnit_actor.id).to eq(user.id)
          end
        end

        context "when the question has a conditional question" do
          context "and the conditional question is not enabled" do
            context "but is applicable because it has an inferred check answers display value" do
              let(:page_id) { "property_postcode" }
              let(:valid_params) do
                {
                  id: lettings_log.id,
                  lettings_log: {
                    page: page_id,
                    postcode_known: "0",
                    postcode_full: "",
                  },
                }
              end

              before do
                lettings_log.update!(postcode_known: 1, postcode_full: "NW1 8RR")
                post "/lettings-logs/#{lettings_log.id}/form", params: valid_params
              end

              it "does not require you to answer that question" do
                expect(response).to redirect_to("/lettings-logs/#{lettings_log.id}/do-you-know-the-local-authority")
              end
            end
          end
        end
      end

      context "with checkbox questions" do
        let(:lettings_log_form_params) do
          {
            id: lettings_log.id,
            lettings_log: {
              page: "accessibility_requirements",
              accessibility_requirements:
                                     %w[housingneeds_b],
            },
          }
        end

        let(:new_lettings_log_form_params) do
          {
            id: lettings_log.id,
            lettings_log: {
              page: "accessibility_requirements",
              accessibility_requirements: %w[housingneeds_c],
            },
          }
        end

        it "sets checked items to true" do
          post "/lettings-logs/#{lettings_log.id}/form", params: lettings_log_form_params
          lettings_log.reload

          expect(lettings_log.housingneeds_b).to eq(1)
        end

        it "sets previously submitted items to false when resubmitted with new values" do
          post "/lettings-logs/#{lettings_log.id}/form", params: new_lettings_log_form_params
          lettings_log.reload

          expect(lettings_log.housingneeds_b).to eq(0)
          expect(lettings_log.housingneeds_c).to eq(1)
        end

        context "with a page having checkbox and non-checkbox questions" do
          let(:tenant_code) { "BZ355" }
          let(:lettings_log_form_params) do
            {
              id: lettings_log.id,
              lettings_log: {
                page: "accessibility_requirements",
                accessibility_requirements:
                                       %w[ housingneeds_a
                                           housingneeds_f],
                tenancycode: tenant_code,
              },
            }
          end
          let(:questions_for_page) do
            [
              Form::Question.new(
                "accessibility_requirements",
                {
                  "type" => "checkbox",
                  "answer_options" =>
                  { "housingneeds_a" => "Fully wheelchair accessible housing",
                    "housingneeds_b" => "Wheelchair access to essential rooms",
                    "housingneeds_c" => "Level access housing",
                    "housingneeds_f" => "Other disability requirements",
                    "housingneeds_g" => "No disability requirements",
                    "divider_a" => true,
                    "housingneeds_h" => "Don’t know" },
                }, nil
              ),
              Form::Question.new("tenancycode", { "type" => "text" }, nil),
            ]
          end
          let(:page) { lettings_log.form.get_page("accessibility_requirements") }

          it "updates both question fields" do
            allow(page).to receive(:questions).and_return(questions_for_page)
            post "/lettings-logs/#{lettings_log.id}/form", params: lettings_log_form_params
            lettings_log.reload

            expect(lettings_log.housingneeds_a).to eq(1)
            expect(lettings_log.housingneeds_f).to eq(1)
            expect(lettings_log.tenancycode).to eq(tenant_code)
          end
        end
      end

      context "with conditional routing" do
        let(:validator) { lettings_log._validators[nil].first }
        let(:lettings_log_form_conditional_question_yes_params) do
          {
            id: lettings_log.id,
            lettings_log: {
              page: "conditional_question",
              preg_occ: 1,
            },
          }
        end
        let(:lettings_log_form_conditional_question_no_params) do
          {
            id: lettings_log.id,
            lettings_log: {
              page: "conditional_question",
              preg_occ: 2,
            },
          }
        end
        let(:lettings_log_form_conditional_question_wchair_yes_params) do
          {
            id: lettings_log.id,
            lettings_log: {
              page: "property_wheelchair_accessible",
              wchair: 1,
            },
          }
        end

        before do
          allow(validator).to receive(:validate_pregnancy).and_return(true)
        end

        it "routes to the appropriate conditional page based on the question answer of the current page" do
          post "/lettings-logs/#{lettings_log.id}/form", params: lettings_log_form_conditional_question_yes_params
          expect(response).to redirect_to("/lettings-logs/#{lettings_log.id}/conditional-question-yes-page")

          post "/lettings-logs/#{lettings_log.id}/form", params: lettings_log_form_conditional_question_no_params
          expect(response).to redirect_to("/lettings-logs/#{lettings_log.id}/conditional-question-no-page")
        end

        it "routes to the page if at least one of the condition sets is met" do
          post "/lettings-logs/#{lettings_log.id}/form", params: lettings_log_form_conditional_question_wchair_yes_params
          post "/lettings-logs/#{lettings_log.id}/form", params: lettings_log_form_conditional_question_no_params
          expect(response).to redirect_to("/lettings-logs/#{lettings_log.id}/conditional-question-yes-page")
        end
      end

      context "when coming from check answers page" do
        context "and navigating to an interruption screen" do
          let(:interrupt_params) do
            {
              id: completed_lettings_log.id,
              lettings_log: {
                page: "net_income_value_check",
                net_income_value_check: value,
              },
            }
          end
          let(:referrer) { "/lettings-logs/#{completed_lettings_log.id}/net-income-value-check?referrer=check_answers" }

          before do
            completed_lettings_log.update!(ecstat1: 1, earnings: 130, hhmemb: 1) # we're not routing to that page, so it gets cleared?
            allow(completed_lettings_log).to receive(:net_income_soft_validation_triggered?).and_return(true)
            allow(completed_lettings_log.form).to receive(:end_date).and_return(Time.zone.today + 1.day)
            post "/lettings-logs/#{completed_lettings_log.id}/form", params: interrupt_params, headers: headers.merge({ "HTTP_REFERER" => referrer })
          end

          context "when yes is answered" do
            let(:value) { 0 }

            it "redirects back to check answers if 'yes' is selected" do
              expect(response).to redirect_to("/lettings-logs/#{completed_lettings_log.id}/income-and-benefits/check-answers")
            end
          end

          context "when no is answered" do
            let(:value) { 1 }

            it "redirects to the previous question if 'no' is selected" do
              expect(response).to redirect_to("/lettings-logs/#{completed_lettings_log.id}/net-income?referrer=check_answers")
            end
          end
        end
      end

      context "with lettings logs that are not owned or managed by your organisation" do
        let(:answer) { 25 }
        let(:other_user) { create(:user) }
        let(:unauthorized_lettings_log) do
          create(
            :lettings_log,
            created_by: other_user,
          )
        end

        before do
          post "/lettings-logs/#{unauthorized_lettings_log.id}/form", params: {}
        end

        it "does not let you post form answers to lettings logs you don't have access to" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
