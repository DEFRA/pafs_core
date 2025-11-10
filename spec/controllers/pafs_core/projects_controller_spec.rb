# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ProjectsController do
  routes { PafsCore::Engine.routes }

  let(:user) { create(:user) }
  let(:area) { PafsCore::Area.last }
  let(:project) { create(:project) }

  before do
    create(:country, :with_full_hierarchy)
    user.user_areas.create(area_id: area.id, primary: true)
    project.area_projects.create(area_id: area.id)

    allow(subject).to receive(:current_resource) { user }
  end

  describe "GET index" do
    it "assigns @projects" do
      get :index
      expect(assigns(:projects)).to include(project.reload)
    end

    it "renders the index template for html responses" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "GET show" do
    # By default, rspec suppresses view rendering in controller specs
    render_views

    it "assigns @project" do
      get :show, params: { id: project.to_param }
      expect(assigns(:project)).to eq(project)
    end

    it "renders the show template" do
      get :show, params: { id: project.to_param }
      expect(response).to render_template("show")
    end

    context "for carbon values changed message" do
      shared_examples "does not show the carbon values changes message" do
        it { expect(response.body).not_to include I18n.t("pafs_core.summary.carbon_values_have_changed_message") }
      end

      shared_examples "shows the carbon values changed message" do
        it { expect(response.body).to include I18n.t("pafs_core.summary.carbon_values_have_changed_message") }
      end

      context "when carbon input values have not yet been stored" do
        let(:project) { create(:full_project, :with_funding_values) }

        before { get :show, params: { id: project.to_param } }

        it { expect(project.carbon_values_hexdigest).to be_nil }

        it_behaves_like "does not show the carbon values changes message"
      end

      context "when carbon input values have been stored" do
        let(:project) { create(:full_project, :with_funding_values, :with_carbon_values) }

        context "when the hexdigest has not been calculated" do
          before { get :show, params: { id: project.to_param } }

          it { expect(project.carbon_values_hexdigest).to be_nil }

          it_behaves_like "shows the carbon values changed message"
        end

        context "when the hexdigest has been calculated and stored" do
          before { project.carbon_values_update_hexdigest }

          context "when carbon input values have not been updated since the hexdigest was stored" do
            before do
              get :show, params: { id: project.to_param }
            end

            it { expect(project.carbon_values_hexdigest).not_to be_nil }

            it_behaves_like "does not show the carbon values changes message"
          end

          context "when carbon input values have been updated since the hexdigest was stored" do
            before do
              project.update(carbon_cost_operation: project.carbon_cost_operation + 1)

              get :show, params: { id: project.to_param }
            end

            it_behaves_like "shows the carbon values changed message"
          end

          context "when the funding values have been updated since the hexdigest was stored" do
            before do
              project.carbon_values_update_hexdigest

              project.update(ready_for_service_year: project.ready_for_service_year - 1)
              project.update(carbon_cost_operation: nil)
              financial_years = project.start_construction_year..project.ready_for_service_year
              project.funding_values.select { |x| financial_years.include?(x.financial_year) }.map { |fv| fv.update(fcerm_gia: 987) }

              get :show, params: { id: project.to_param }
            end

            it_behaves_like "shows the carbon values changed message"
          end
        end
      end
    end
  end

  describe "GET pipeline" do
    it "renders the pipeline template" do
      get :pipeline
      expect(response).to render_template("pipeline")
    end
  end

  describe "GET step" do
    it "assigns @project with the appropriate step class" do
      get :step, params: { id: project.to_param, step: "project_name" }
      expect(assigns(:project)).to be_instance_of PafsCore::ProjectNameStep
    end

    it "renders the template specified by the selected step" do
      get :step, params: { id: project.to_param, step: "project_name" }
      expect(response).to render_template "project_name"
    end
  end

  describe "PATCH save" do
    it "assigns @project with appropriate step class" do
      get :step, params: { id: project.to_param, step: "risks" }
      expect(assigns(:project)).to be_instance_of PafsCore::RisksStep
    end

    context "when given valid data to save" do
      it "updates the project" do
        patch :save, params: { id: project.to_param, step: "project_name", project_name_step: { name: "Wigwam" } }
        expect(PafsCore::Project.find(project.id).name).to eq "Wigwam"
      end

      it "redirects to the next step or summary" do
        patch :save, params: { id: project.to_param, step: "project_name", project_name_step: { name: "Haystack" } }
        expect(response).to redirect_to project_path(id: project.to_param, anchor: "project-name")
      end

      it "stores updated_by" do
        patch :save, params: { id: project.to_param, step: "project_name", project_name_step: { name: "Haystack" } }
        expect(PafsCore::Project.find(project.id).updated_by).to eq user
      end
    end

    context "when user completes a section" do
      context "when saving the project name" do
        let(:params) do
          {
            id: project.to_param,
            step: "project_name",
            project_name_step: {
              name: "Haystack"
            }
          }
        end

        it "redirects to the project name" do
          patch :save, params: params
          expect(response).to redirect_to project_path(id: project.to_param, anchor: "project-name")
        end
      end

      context "when saving the project type" do
        let(:params) do
          {
            project_type_step: {
              id: 4,
              project_type: "DEF"
            },
            commit: "Save and continue",
            id: project.to_param,
            step: "project_type"
          }
        end

        it "redirects to the project type" do
          patch :save, params: params
          expect(response).to redirect_to project_path(id: project.to_param, anchor: "project-type")
        end
      end

      context "when saving the financial year" do
        let(:params) do
          {
            financial_year_step: {
              id: "4",
              project_end_financial_year: Time.zone.today.year
            },
            commit: "Save and continue",
            id: project.to_param,
            step: "financial_year"
          }
        end

        it "redirects to the financial year" do
          patch :save, params: params
          expect(response).to redirect_to project_path(id: project.to_param, anchor: "financial-year")
        end
      end

      context "when saving the location" do
        let(:params) do
          {
            commit: "Save and continue",
            id: project.to_param,
            step: "benefit_area_file_summary"
          }
        end

        it "redirects to the location" do
          patch :save, params: params
          expect(response).to redirect_to project_path(id: project.to_param, anchor: "location")
        end
      end

      context "when saving the important dates" do
        let(:params) do
          {
            ready_for_service_date_step: {
              ready_for_service_month: 7,
              ready_for_service_year: "2022"
            },
            commit: "Save and continue",
            id: project.to_param,
            step: "ready_for_service_date"
          }
        end

        it "redirects to the important dates" do
          allow_any_instance_of(PafsCore::Project).to receive(:start_construction_year).and_return(2020)
          allow_any_instance_of(PafsCore::Project).to receive(:start_construction_month).and_return(8)

          patch :save, params: params
          expect(response).to redirect_to project_path(id: project.to_param, anchor: "key-dates")
        end
      end

      context "when saving the funding source" do
        let(:step_params) do
          {
            funding_sources_step: {
              fcerm_gia: "1",
              local_levy: "1"
            },
            commit: "Save and continue",
            id: project.to_param,
            step: "funding_sources"
          }
        end

        let(:params) do
          {
            funding_values_step: {
              funding_values_attributes: {
                "0": {
                  financial_year: first_year.financial_year,
                  id: first_year.id,
                  fcerm_gia: first_year.fcerm_gia,
                  local_levy: first_year.local_levy
                },
                "1": {
                  financial_year: second_year.financial_year,
                  id: second_year.id,
                  fcerm_gia: second_year.fcerm_gia,
                  local_levy: second_year.local_levy
                },
                "2": {
                  financial_year: third_year.financial_year,
                  id: third_year.id,
                  fcerm_gia: third_year.fcerm_gia,
                  local_levy: third_year.local_levy
                },
                "3": {
                  financial_year: fourth_year.financial_year,
                  id: fourth_year.id,
                  fcerm_gia: fourth_year.fcerm_gia,
                  local_levy: fourth_year.local_levy
                },
                "4": {
                  financial_year: fifth_year.financial_year,
                  id: fifth_year.id,
                  fcerm_gia: fifth_year.fcerm_gia,
                  local_levy: fifth_year.local_levy
                }
              }
            },
            js_enabled: "1",
            commit: "Save and continue",
            id: project.to_param,
            step: "funding_values"
          }
        end

        let(:first_year) do
          project.funding_values.create(
            financial_year: "-1",
            fcerm_gia: "10",
            local_levy: "20"
          )
        end

        let(:second_year) do
          project.funding_values.create(
            financial_year: "2015",
            fcerm_gia: "",
            local_levy: ""
          )
        end

        let(:third_year) do
          project.funding_values.create(
            financial_year: "2016",
            fcerm_gia: "",
            local_levy: ""
          )
        end

        let(:fourth_year) do
          project.funding_values.create(
            financial_year: "2017",
            fcerm_gia: "",
            local_levy: ""
          )
        end

        let(:fifth_year) do
          project.funding_values.create(
            financial_year: "2018",
            fcerm_gia: "",
            local_levy: ""
          )
        end

        before do
          patch :save, params: step_params
        end

        it "redirects to the funding sources" do
          allow_any_instance_of(PafsCore::Project).to receive(:project_end_financial_year).and_return(2020)

          patch :save, params: params
          expect(response).to redirect_to project_path(id: project.to_param, anchor: "funding-sources")
        end
      end

      context "when saving the earliest start" do
        let(:params) do
          {
            earliest_start_date_step: {
              earliest_start_month: "2",
              earliest_start_year: 1.year.from_now.year
            },
            commit: "Save and continue",
            id: project.to_param,
            step: "earliest_start_date"
          }
        end

        it "redirects to the earliest date" do
          patch :save, params: params
          expect(response).to redirect_to project_step_path(id: project.to_param, step: "could_start_sooner")
        end
      end

      context "when saving could start sooner" do
        let(:params) do
          {
            could_start_sooner_step: {
              could_start_early: "1"
            },
            commit: "Save and continue",
            id: project.to_param,
            step: "could_start_sooner"
          }
        end

        it "redirects to the earliest start date without impact" do
          patch :save, params: params
          expect(response).to redirect_to project_step_path(id: project.to_param, step: "earliest_start_date_with_gia")
        end
      end

      context "when saving the risks" do
        let(:first_flood_project_outcome) do
          project.flood_protection_outcomes.create(
            financial_year: "-1",
            households_at_reduced_risk: "",
            moved_from_very_significant_and_significant_to_moderate_or_low: "",
            households_protected_from_loss_in_20_percent_most_deprived: ""
          )
        end

        let(:second_flood_project_outcome) do
          project.flood_protection_outcomes.create(
            financial_year: "2015",
            households_at_reduced_risk: "",
            moved_from_very_significant_and_significant_to_moderate_or_low: "",
            households_protected_from_loss_in_20_percent_most_deprived: ""
          )
        end

        let(:third_flood_project_outcome) do
          project.flood_protection_outcomes.create(
            financial_year: "2016",
            households_at_reduced_risk: "",
            moved_from_very_significant_and_significant_to_moderate_or_low: "",
            households_protected_from_loss_in_20_percent_most_deprived: ""
          )
        end

        let(:fourth_flood_project_outcome) do
          project.flood_protection_outcomes.create(
            financial_year: "2017",
            households_at_reduced_risk: "",
            moved_from_very_significant_and_significant_to_moderate_or_low: "",
            households_protected_from_loss_in_20_percent_most_deprived: ""
          )
        end

        let(:fifth_flood_project_outcome) do
          project.flood_protection_outcomes.create(
            financial_year: "2018",
            households_at_reduced_risk: "",
            moved_from_very_significant_and_significant_to_moderate_or_low: "",
            households_protected_from_loss_in_20_percent_most_deprived: ""
          )
        end

        let(:params) do
          {
            flood_protection_outcomes_step: {
              reduced_risk_of_households_for_floods: "1",
              flood_protection_outcomes_attributes: {
                "0": {
                  financial_year: first_flood_project_outcome.financial_year,
                  id: first_flood_project_outcome.id,
                  households_at_reduced_risk: first_flood_project_outcome.households_at_reduced_risk,
                  moved_from_very_significant_and_significant_to_moderate_or_low: first_flood_project_outcome.moved_from_very_significant_and_significant_to_moderate_or_low,
                  households_protected_from_loss_in_20_percent_most_deprived: first_flood_project_outcome.households_protected_from_loss_in_20_percent_most_deprived
                },
                "1": {
                  financial_year: second_flood_project_outcome.financial_year,
                  id: second_flood_project_outcome.id,
                  households_at_reduced_risk: second_flood_project_outcome.households_at_reduced_risk,
                  moved_from_very_significant_and_significant_to_moderate_or_low: second_flood_project_outcome.moved_from_very_significant_and_significant_to_moderate_or_low,
                  households_protected_from_loss_in_20_percent_most_deprived: second_flood_project_outcome.households_protected_from_loss_in_20_percent_most_deprived
                },
                "2": {
                  financial_year: third_flood_project_outcome.financial_year,
                  id: third_flood_project_outcome.id,
                  households_at_reduced_risk: third_flood_project_outcome.households_at_reduced_risk,
                  moved_from_very_significant_and_significant_to_moderate_or_low: third_flood_project_outcome.moved_from_very_significant_and_significant_to_moderate_or_low,
                  households_protected_from_loss_in_20_percent_most_deprived: third_flood_project_outcome.households_protected_from_loss_in_20_percent_most_deprived
                },
                "3": {
                  financial_year: fourth_flood_project_outcome.financial_year,
                  id: fourth_flood_project_outcome.id,
                  households_at_reduced_risk: fourth_flood_project_outcome.households_at_reduced_risk,
                  moved_from_very_significant_and_significant_to_moderate_or_low: fourth_flood_project_outcome.moved_from_very_significant_and_significant_to_moderate_or_low,
                  households_protected_from_loss_in_20_percent_most_deprived: fourth_flood_project_outcome.households_protected_from_loss_in_20_percent_most_deprived
                },
                "4": {
                  financial_year: fifth_flood_project_outcome.financial_year,
                  id: fifth_flood_project_outcome.id,
                  households_at_reduced_risk: fifth_flood_project_outcome.households_at_reduced_risk,
                  moved_from_very_significant_and_significant_to_moderate_or_low: fifth_flood_project_outcome.moved_from_very_significant_and_significant_to_moderate_or_low,
                  households_protected_from_loss_in_20_percent_most_deprived: fifth_flood_project_outcome.households_protected_from_loss_in_20_percent_most_deprived
                }
              }
            },
            js_enabled: "1",
            commit: "Save and continue",
            id: project.to_param,
            step: "flood_protection_outcomes"
          }
        end

        it "redirects to the risks" do
          allow_any_instance_of(PafsCore::Project).to receive(:project_end_financial_year).and_return(2020)

          patch :save, params: params
          expect(response).to redirect_to project_path(id: project.to_param, anchor: "risks")
        end
      end

      context "when saving a standard of protection" do
        let(:params) do
          {
            standard_of_protection_after_step: {
              id: "4",
              flood_protection_after: "3"
            },
            commit: "Save and continue",
            id: project.to_param,
            step: "standard_of_protection_after"
          }
        end

        it "redirects to the standard of protection" do
          patch :save, params: params
          expect(response).to redirect_to project_path(id: project.to_param, anchor: "standard-of-protection")
        end
      end

      context "when saving an approach" do
        let(:params) do
          {
            approach_step: {
              approach: "Some text"
            },
            commit: "Save and continue",
            id: project.to_param,
            step: "approach"
          }
        end

        it "redirects to the approach" do
          patch :save, params: params
          expect(response).to redirect_to project_path(id: project.to_param, anchor: "approach")
        end
      end

      context "when saving the environmental outcomes" do
        let(:params) do
          {
            kilometres_of_watercourse_enhanced_or_created_single_step: {
              id: "4",
              kilometres_of_watercourse_enhanced_or_created_single: "100"
            },
            commit: "Save and continue",
            id: project.to_param,
            step: "kilometres_of_watercourse_enhanced_or_created_single"
          }
        end

        it "redirects to the environmental outcomes" do
          patch :save, params: params
          expect(response).to redirect_to project_path(id: project.to_param, anchor: "environmental-outcomes")
        end
      end

      context "when saving a project urgency" do
        let(:params) do
          {
            urgency_step: {
              id: 4,
              urgency_reason: "not_urgent"
            },
            commit: "Save and continue",
            id: project.to_param,
            step: "urgency"
          }
        end

        it "redirects to the project urgency" do
          patch :save, params: params
          expect(response).to redirect_to project_path(id: project.to_param, anchor: "urgency")
        end
      end

      context "when saving a project calculator" do
        let(:params) do
          {
            commit: "Save and continue",
            id: project.to_param,
            step: "funding_calculator_summary"
          }
        end

        it "redirects to the funding calculator" do
          patch :save, params: params
          expect(response).to redirect_to project_path(id: project.to_param, anchor: "funding-calculator")
        end
      end

      context "when saving a project confidence assessment" do
        let(:params) do
          {
            confidence_secured_partnership_funding_step: {
              confidence_secured_partnership_funding: "high"
            },
            commit: "Save and continue",
            id: project.to_param,
            step: "confidence_secured_partnership_funding"
          }
        end

        it "redirects to the confidenxe" do
          patch :save, params: params
          expect(response).to redirect_to project_path(id: project.to_param, anchor: "confidence")
        end
      end
    end

    context "when given invalid data to save" do
      it "does not update the project" do
        patch :save, params: { id: project.to_param, step: "project_type", project_type_step: { project_type: "1234" } }
        expect(PafsCore::Project.find(project.id).project_type).not_to eq "1234"
      end

      it "renders the template specified by the selected step" do
        patch :save, params: { id: project.to_param, step: "project_type", project_type_step: { project_type: "1234" } }
        expect(response).to render_template("project_type")
      end
    end
  end
end
