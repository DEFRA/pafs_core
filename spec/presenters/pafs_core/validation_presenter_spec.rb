# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ValidationPresenter do

  subject(:test_subject) { described_class.new(build(:full_project)) }

  let(:flood_options) do
    ["Very significant",
     "Significant",
     "Moderate",
     "Low"]
  end
  let(:coastal_before_options) do
    ["Less than 1 year",
     "1 to 4 years",
     "5 to 9 years",
     "10 years or more"]
  end
  let(:coastal_after_options) do
    ["Less than 10 years",
     "10 to 19 years",
     "20 to 49 years",
     "50 years or more"]
  end
  let(:not_provided_text) { "<em>Not provided</em>" }

  shared_examples "failed validation example" do |attribute, key = nil, error_msg = nil|
    it "returns false" do
      expect(subject.public_send(attribute)).to be false
    end

    if key.present? && error_msg.present?
      it "sets an error message" do
        subject.public_send(attribute)
        expect(subject.errors[key]).to include error_msg
      end
    end
  end

  shared_examples "successful validation example" do |attribute|
    it "returns true" do
      expect(subject.public_send(attribute)).to be true
    end
  end

  describe "#project_name_complete?" do
    context "when the project name is blank" do
      before { subject.name = "" }

      it_behaves_like "failed validation example", :project_name_complete?, :project_name, "Tell us the project name"
    end

    context "when the project name contains invalid characters" do
      invalid_names = ["Project/123", "Project@Name", "Project#ABC"]

      invalid_names.each do |invalid_name|
        context "with name '#{invalid_name}'" do
          before { subject.name = invalid_name }

          it_behaves_like "failed validation example", :project_name_complete?, :project_name, "The project name must only contain letters, underscores, hyphens and numbers"
        end
      end
    end

    context "when the project name is not unique" do
      before do
        existing_project = create(:project, name: "Existing Project")
        subject.name = existing_project.name
      end

      it_behaves_like "failed validation example", :project_name_complete?, :project_name, "The project name already exists. Your project must have a unique name."
    end

    context "when the project name is valid and unique" do
      valid_names = ["Project 123", "PROJECT_ABC", "project-xyz", "Simple Project Name"]

      valid_names.each do |valid_name|
        context "with name '#{valid_name}'" do
          before { subject.name = valid_name }

          it_behaves_like "successful validation example", :project_name_complete?
        end
      end
    end

    context "when updating an existing project" do
      subject { described_class.new(existing_project) }

      let(:existing_project) { create(:project, name: "Existing Project") }

      it "allows the project to keep its current name" do
        expect(subject.project_name_complete?).to be true
      end

      it "allows the project to change its name" do
        subject.name = "Updated Project Name"
        expect(subject.project_name_complete?).to be true
      end
    end
  end

  describe "#project_type_complete?" do
    it "always returns true" do
      expect(subject.project_type_complete?).to be true
    end
  end

  describe "#financial_year_complete?" do
    it "always returns true" do
      expect(subject.financial_year_complete?).to be true
    end
  end

  describe "#location_complete?" do
    context "when location has been set" do
      before { subject.grid_reference = "ST 58198 72725" }

      context "when a benefit area file has been uploaded" do
        it "returns true" do
          subject.benefit_area_file_name = "my_file.jpg"
          expect(subject.location_complete?).to be true
        end
      end

      context "when a benefit area file has not been uploaded" do
        before { subject.benefit_area_file_name = nil }

        it_behaves_like "failed validation example", :location_complete?, :location, "Tell us the location of the project"
      end
    end

    context "when location has not been set" do
      before { subject.project_location = nil }

      it_behaves_like "failed validation example", :location_complete?, :location, "Tell us the location of the project"
    end
  end

  describe "#carbon_complete?" do
    context "when carbon_operational_cost_forecast has been set" do
      context "when set to a positive value" do
        before { subject.carbon_operational_cost_forecast = 50.25 }

        it { expect(subject).to be_carbon_complete }
      end

      context "when set to zero" do
        before { subject.carbon_operational_cost_forecast = 0 }

        it { expect(subject).to be_carbon_complete }
      end

      context "when set to a negative value" do
        before { subject.carbon_operational_cost_forecast = -100 }

        it_behaves_like "failed validation example", :carbon_complete?, :carbon, "Tell us about the carbon cost of the project"
      end
    end

    context "when carbon_operational_cost_forecast has not been set" do
      before { subject.carbon_operational_cost_forecast = nil }

      it_behaves_like "failed validation example", :carbon_complete?, :carbon, "Tell us about the carbon cost of the project"
    end
  end

  describe "#key_dates_complete?" do
    let(:future_start_date) { 1.month.from_now }

    before do
      subject.start_outline_business_case_month = future_start_date.month
      subject.start_outline_business_case_year = future_start_date.year
      subject.award_contract_month = future_start_date.month
      subject.award_contract_year = future_start_date.year + 1
      subject.start_construction_month = future_start_date.month
      subject.start_construction_year = future_start_date.year + 2
      subject.ready_for_service_month = future_start_date.month
      subject.ready_for_service_year = future_start_date.year + 3
      subject.project_end_financial_year = future_start_date.year + 4
    end

    context "when the key dates are all present and in future" do
      it "returns true" do
        expect(subject.key_dates_complete?).to be true
      end
    end

    context "when one of the key dates is missing" do
      let(:dates) do
        %i[start_outline_business_case_year
           start_outline_business_case_month
           award_contract_year
           award_contract_month
           start_construction_year
           start_construction_month
           ready_for_service_year
           ready_for_service_month]
      end

      it "returns false" do
        dates.each do |date|
          m = "#{date}="
          subject.send(m, nil)
          expect(subject.key_dates_complete?).to be false
          subject.send(m, 12)
        end
      end

      it "sets an error message" do
        dates.each do |date|
          m = "#{date}="
          subject.send(m, nil)
          subject.key_dates_complete?
          expect(subject.errors[:key_dates]).to include "Tell us the project's important dates"
          subject.send(m, 12)
        end
      end
    end

    context "when start_outline_business_case is in the past" do
      before { subject.start_outline_business_case_year = 2020 }

      it_behaves_like "failed validation example", :key_dates_complete?, :key_dates, "The record will remain in draft. One or more of the dates entered in your 'Important Dates’ section is in the past, please revise and resubmit your proposal."
    end
  end

  describe "#funding_sources_complete?"

  describe "#earliest_start_complete?" do
    context "when earliest_start_month and earliest_start_year are not present" do
      before do
        subject.earliest_start_month = nil
        subject.earliest_start_year = nil
      end

      it_behaves_like "failed validation example", :earliest_start_complete?
    end

    context "when earliest_start_month and earliest_start_year are present and in future" do
      before do
        subject.earliest_start_month = 2
        subject.earliest_start_year = Time.zone.today.year + 1
      end

      context "when could_start_early is nil" do
        it "returns false" do
          subject.could_start_early = nil
          expect(subject.earliest_start_complete?).to be false
        end
      end

      context "when could_start_early is true" do
        before { subject.could_start_early = true }

        context "when earliest_with_gia_year is present" do
          it "returns true" do
            subject.earliest_with_gia_month = 2
            subject.earliest_with_gia_year = Time.zone.today.year + 1
            expect(subject.earliest_start_complete?).to be true
          end
        end

        context "when earliest_with_gia_year is not present" do
          it "returns false" do
            subject.earliest_with_gia_month = nil
            subject.earliest_with_gia_year = nil
            expect(subject.earliest_start_complete?).to be false
          end
        end
      end

      context "when could_start_early is false" do
        before { subject.could_start_early = false }

        it "returns true" do
          expect(subject.earliest_start_complete?).to be true
        end
      end
    end

    context "when earliest_start is in the past" do
      context "when could_start_early is false" do
        before do
          subject.could_start_early = false
          subject.earliest_start_year = 2020
        end

        it_behaves_like "failed validation example", :earliest_start_complete?, :earliest_start, "The record will remain in draft. One or more of the dates entered in your 'Earliest start’ section is in the past, please revise and resubmit your proposal."
      end

      context "when could_start_early is true" do
        before do
          subject.earliest_with_gia_month = 2
          subject.earliest_with_gia_year = Time.zone.today.year + 1
          subject.could_start_early = true
          subject.earliest_start_year = 2020
        end

        it_behaves_like "failed validation example", :earliest_start_complete?, :earliest_start, "The record will remain in draft. One or more of the dates entered in your 'Earliest start’ section is in the past, please revise and resubmit your proposal."
      end
    end
  end

  describe "#risks_complete?" do
    context "when no risks have been selected" do
      before do
        PafsCore::Risks::RISKS.each do |r|
          subject.send("#{r}=", nil)
        end
      end

      it_behaves_like "failed validation example", :risks_complete?, :risks, "Tell us the risks the project protects against and the households benefitting."
    end

    context "when risks are selected" do
      before do
        PafsCore::Risks::RISKS.each do |r|
          subject.send("#{r}=", nil)
        end
        subject.fluvial_flooding = true
        subject.flood_protection_outcomes << build(:flood_protection_outcomes)
      end

      context "when a single risk is selected" do
        it "returns true" do
          expect(subject.risks_complete?).to be true
        end
      end

      context "when multiple risks are selected" do
        before { subject.tidal_flooding = true }

        context "when a main risk is set" do
          before { subject.main_risk = "tidal_flooding" }

          it "returns true" do
            expect(subject.risks_complete?).to be true
          end
        end

        context "when a main risk has not been set" do
          before { subject.main_risk = nil }

          it_behaves_like "failed validation example", :risks_complete?, :risks, "Tell us the risks the project protects against and the households benefitting."
        end
      end
    end
  end

  describe "#natural_flood_risk_measures_complete?" do
    context "when the natural flood risk measures have not been set" do
      before { subject.natural_flood_risk_measures_included = nil }

      it_behaves_like "failed validation example", :natural_flood_risk_measures_complete?
    end

    context "when the project includes no natural flood risk measures" do
      before { subject.natural_flood_risk_measures_included = false }

      it "returns true" do
        expect(subject.natural_flood_risk_measures_complete?).to be true
      end
    end

    context "when the project includes natural flood risk measures" do
      before { subject.natural_flood_risk_measures_included = true }

      context "when no flood risk measures have been selected" do
        it_behaves_like "failed validation example", :natural_flood_risk_measures_complete?
      end

      context "when flood risk measures have been selected" do
        before { subject.river_restoration = true }

        context "when no cost has been provided" do
          it_behaves_like "failed validation example", :natural_flood_risk_measures_complete?
        end

        context "when the cost has been provided" do
          before { subject.natural_flood_risk_measures_cost = 123.45 }

          it "returns true" do
            expect(subject.natural_flood_risk_measures_complete?).to be true
          end
        end
      end
    end
  end

  describe "#standard_of_protection_complete?"

  describe "#approach_complete?"

  describe "#environmental_outcomes_complete?" do
    context "when environmental_benefits is set to nil" do
      before { subject.environmental_benefits = nil }

      it_behaves_like "failed validation example", :environmental_outcomes_complete?
    end

    context "when environmental_benefits is set to false" do
      before { subject.environmental_benefits = false }

      it "returns true" do
        expect(subject.environmental_outcomes_complete?).to be true
      end
    end

    context "when environmental_benefits is set to true" do
      before { subject.environmental_benefits = true }

      context "when no environmental benefits have been selected" do
        it_behaves_like "failed validation example", :environmental_outcomes_complete?, :environmental_outcomes, "Tell us the project's environmental outcomes"
      end

      context "when at least one environmental benefit has been elected" do
        before do
          subject.arable_land = true
          %i[intertidal_habitat grassland woodland wet_woodland wetland_or_wet_grassland heathland ponds_lakes comprehensive_restoration partial_restoration create_habitat_watercourse].each do |benefit|
            subject.send("#{benefit}=", false)
          end
        end

        context "when the figure hasn't been provided" do
          it_behaves_like "failed validation example", :environmental_outcomes_complete?
        end

        context "when the figure has been provided" do
          before { subject.hectares_of_arable_land_lake_habitat_created_or_enhanced = 12 }

          it "returns true" do
            expect(subject.environmental_outcomes_complete?).to be true
          end
        end
      end
    end
  end

  describe "#urgency_complete?"

  describe "#funding_calculator_complete?" do
    subject { described_class.new(project) }

    let(:project_type) { "DEF" }
    let(:project) { create(:full_project, project_type: project_type) }

    context "when project type is not DEF or CM" do
      let(:project_type) { "PLP" }

      context "with no PFC attached" do
        it "returns true" do
          expect(subject.funding_calculator_complete?).to be true
        end
      end
    end

    context "when project type is DEF or CM" do
      let(:project_type) { "DEF" }

      context "with no PFC attached" do
        it_behaves_like "failed validation example", :funding_calculator_complete?
      end

      context "with a PFC attached" do
        before do
          file_path = Rails.root.join("..", "fixtures", "calculators", filename)
          file = File.open file_path
          storage = PafsCore::DevelopmentFileStorageService.new
          dest_file = File.join(project.storage_path, filename)
          storage.upload(file, dest_file)
          project.funding_calculator_file_name = filename
        end

        context "with a v8 PFC attached" do
          let(:filename) { "v8.xlsx" }

          it "returns false" do
            expect(subject.funding_calculator_complete?).to be false
          end
        end

        context "with a 2020 v1 PFC attached" do
          let(:filename) { "v9old.xlsx" }

          it_behaves_like "failed validation example", :funding_calculator_complete?
        end

        context "with a 2020 v2 PFC attached" do
          let(:filename) { "v9.xlsx" }

          it "returns true" do
            expect(subject.funding_calculator_complete?).to be true
          end
        end
      end
    end
  end

  describe "#check_key_dates_within_project_lifetime_range" do
    context "when dates are within the project lifetime range" do
      it_behaves_like "successful validation example", :check_key_dates_within_project_lifetime_range
    end

    context "when the date is outside of the project lifetime range" do
      context "when ready_for_service date is before the earliest_start date" do
        before { subject.ready_for_service_year = 2015 }

        it_behaves_like "failed validation example",
                        :check_key_dates_within_project_lifetime_range, :key_dates,
                        I18n.t("pafs_core.validation_presenter.errors.key_dates_outside_project_lifetime")
      end

      context "when ready_for_service date is after the project_end_financial_year" do
        before { subject.ready_for_service_year = 2030 }

        it_behaves_like "failed validation example",
                        :check_key_dates_within_project_lifetime_range, :key_dates,
                        I18n.t("pafs_core.validation_presenter.errors.key_dates_outside_project_lifetime")
      end
    end
  end

  describe "#check_funding_values_within_project_lifetime_range" do
    subject { described_class.new(project) }

    let(:project) { create(:full_project, fcerm_gia: true, local_levy: true) }

    context "when funding value financial year is within the project lifetime range" do
      before do
        create(:funding_value, project: project, financial_year: 2020, fcerm_gia: 10, local_levy: 20)
      end

      it_behaves_like "successful validation example", :check_funding_values_within_project_lifetime_range
    end

    context "when funding value financial year is before the earliest_start date" do
      before do
        project.update(earliest_start_year: 2022)
        create(:funding_value, project: project, financial_year: 2015, fcerm_gia: 10, local_levy: 20)
      end

      it_behaves_like "failed validation example",
                      :check_funding_values_within_project_lifetime_range, :funding_sources,
                      I18n.t("pafs_core.validation_presenter.errors.funding_data_outside_project_lifetime")
    end

    context "when funding value financial year is after the project_end_financial_year" do
      before do
        project.update(project_end_financial_year: 2027)
        create(:funding_value, project: project, financial_year: 2028, fcerm_gia: 10, local_levy: 20)
      end

      it_behaves_like "failed validation example",
                      :check_funding_values_within_project_lifetime_range, :funding_sources,
                      I18n.t("pafs_core.validation_presenter.errors.funding_data_outside_project_lifetime")
    end

    context "when public contribution financial year is within the project lifetime range" do
      before do
        create(:funding_value, :with_public_contributor, project: project)
      end

      it_behaves_like "successful validation example", :check_funding_values_within_project_lifetime_range
    end

    context "when public contribution financial year is before the earliest_start date" do
      before do
        project.update(earliest_start_year: 2022)
        create(:funding_value, :with_public_contributor, project: project, financial_year: 2015)
      end

      it_behaves_like "failed validation example",
                      :check_funding_values_within_project_lifetime_range, :funding_sources,
                      I18n.t("pafs_core.validation_presenter.errors.funding_data_outside_project_lifetime")
    end

    context "when public contribution financial year is after the project_end_financial_year" do
      before do
        project.update(project_end_financial_year: 2027)
        create(:funding_value, :with_public_contributor, project: project, financial_year: 2028)
      end

      it_behaves_like "failed validation example",
                      :check_funding_values_within_project_lifetime_range, :funding_sources,
                      I18n.t("pafs_core.validation_presenter.errors.funding_data_outside_project_lifetime")
    end

    context "when private contribution financial year is within the project lifetime range" do
      before do
        create(:funding_value, :with_private_contributor, project: project)
      end

      it_behaves_like "successful validation example", :check_funding_values_within_project_lifetime_range
    end

    context "when private contribution financial year is before the earliest_start date" do
      before do
        project.update(earliest_start_year: 2022)
        create(:funding_value, :with_private_contributor, project: project, financial_year: 2015)
      end

      it_behaves_like "failed validation example",
                      :check_funding_values_within_project_lifetime_range, :funding_sources,
                      I18n.t("pafs_core.validation_presenter.errors.funding_data_outside_project_lifetime")
    end

    context "when private contribution financial year is after the project_end_financial_year" do
      before do
        project.update(project_end_financial_year: 2027)
        create(:funding_value, :with_private_contributor, project: project, financial_year: 2028)
      end

      it_behaves_like "failed validation example",
                      :check_funding_values_within_project_lifetime_range, :funding_sources,
                      I18n.t("pafs_core.validation_presenter.errors.funding_data_outside_project_lifetime")
    end

    context "when other ea contribution financial year is within the project lifetime range" do
      before do
        create(:funding_value, :with_other_ea_contributor, project: project)
      end

      it_behaves_like "successful validation example", :check_funding_values_within_project_lifetime_range
    end

    context "when other ea contribution financial year is before the earliest_start date" do
      before do
        project.update(earliest_start_year: 2022)
        create(:funding_value, :with_other_ea_contributor, project: project, financial_year: 2015)
      end

      it_behaves_like "failed validation example",
                      :check_funding_values_within_project_lifetime_range, :funding_sources,
                      I18n.t("pafs_core.validation_presenter.errors.funding_data_outside_project_lifetime")
    end

    context "when other ea contribution financial year is after the project_end_financial_year" do
      before do
        project.update(project_end_financial_year: 2027)
        create(:funding_value, :with_other_ea_contributor, project: project, financial_year: 2028)
      end

      it_behaves_like "failed validation example",
                      :check_funding_values_within_project_lifetime_range, :funding_sources,
                      I18n.t("pafs_core.validation_presenter.errors.funding_data_outside_project_lifetime")
    end

    context "when multiple funding values are outside the project lifetime range" do
      before do
        create(:funding_value, :with_public_contributor, project: project, financial_year: 2015)
        create(:funding_value, :with_other_ea_contributor, project: project, financial_year: 2028)
      end

      it_behaves_like "failed validation example",
                      :check_funding_values_within_project_lifetime_range, :funding_sources,
                      I18n.t("pafs_core.validation_presenter.errors.funding_data_outside_project_lifetime")

      it "shows only one error message" do
        subject.check_funding_values_within_project_lifetime_range
        expect(subject.errors[:funding_sources].count).to eq(1)
      end
    end
  end

  describe "#check_outcomes_within_project_lifetime_range" do
    subject { described_class.new(project) }

    let(:project) { create(:full_project) }

    context "when outcome financial year is within the project lifetime range" do
      before do
        create(:flood_protection_outcomes, project: project, financial_year: 2020)
      end

      it_behaves_like "successful validation example", :check_outcomes_within_project_lifetime_range
    end

    context "when outcome financial year is before the earliest_start date" do
      before do
        project.update(earliest_start_year: 2022)
        create(:flood_protection_outcomes, project: project, financial_year: 2015)
      end

      it_behaves_like "failed validation example",
                      :check_outcomes_within_project_lifetime_range, :risks,
                      I18n.t("pafs_core.validation_presenter.errors.outcome_outside_project_lifetime")
    end

    context "when outcome financial year is after the project_end_financial_year" do
      before do
        project.update(project_end_financial_year: 2027)
        create(:flood_protection_outcomes, project: project, financial_year: 2028)
      end

      it_behaves_like "failed validation example",
                      :check_outcomes_within_project_lifetime_range, :risks,
                      I18n.t("pafs_core.validation_presenter.errors.outcome_outside_project_lifetime")
    end

    context "when multiple outcomes are outside the project lifetime range" do
      before do
        create(:flood_protection_outcomes, project: project, financial_year: 2015)
        create(:flood_protection_outcomes, project: project, financial_year: 2028)
      end

      it_behaves_like "failed validation example",
                      :check_outcomes_within_project_lifetime_range, :risks,
                      I18n.t("pafs_core.validation_presenter.errors.outcome_outside_project_lifetime")

      it "shows only one error message" do
        subject.check_outcomes_within_project_lifetime_range
        expect(subject.errors[:risks].count).to eq(1)
      end
    end
  end

  describe "#check_outcomes_2040_within_project_lifetime_range" do
    subject { described_class.new(project) }

    let(:project) { create(:full_project) }

    context "when outcome financial year is within the project lifetime range" do
      before do
        create(:flood_protection2040_outcomes, project: project, financial_year: 2020)
      end

      it_behaves_like "successful validation example", :check_outcomes_2040_within_project_lifetime_range
    end

    context "when outcome financial year is before the earliest_start date" do
      before do
        project.update(earliest_start_year: 2022)
        create(:flood_protection2040_outcomes, project: project, financial_year: 2015)
      end

      it_behaves_like "failed validation example",
                      :check_outcomes_2040_within_project_lifetime_range, :risks,
                      I18n.t("pafs_core.validation_presenter.errors.outcome_outside_project_lifetime")
    end

    context "when outcome financial year is after the project_end_financial_year" do
      before do
        project.update(project_end_financial_year: 2027)
        create(:flood_protection2040_outcomes, project: project, financial_year: 2028)
      end

      it_behaves_like "failed validation example",
                      :check_outcomes_2040_within_project_lifetime_range, :risks,
                      I18n.t("pafs_core.validation_presenter.errors.outcome_outside_project_lifetime")
    end

    context "when multiple outcomes are outside the project lifetime range" do
      before do
        create(:flood_protection2040_outcomes, project: project, financial_year: 2015)
        create(:flood_protection2040_outcomes, project: project, financial_year: 2028)
      end

      it_behaves_like "failed validation example",
                      :check_outcomes_2040_within_project_lifetime_range, :risks,
                      I18n.t("pafs_core.validation_presenter.errors.outcome_outside_project_lifetime")

      it "shows only one error message" do
        subject.check_outcomes_2040_within_project_lifetime_range
        expect(subject.errors[:risks].count).to eq(1)
      end
    end
  end

  describe "#check_coastal_outcomes_within_project_lifetime_range" do
    subject { described_class.new(project) }

    let(:project) { create(:full_project) }

    context "when outcome financial year is within the project lifetime range" do
      before do
        create(:coastal_erosion_protection_outcomes, project: project, financial_year: 2020)
      end

      it_behaves_like "successful validation example", :check_coastal_outcomes_within_project_lifetime_range
    end

    context "when outcome financial year is before the earliest_start date" do
      before do
        project.update(earliest_start_year: 2022)
        create(:coastal_erosion_protection_outcomes, project: project, financial_year: 2015)
      end

      it_behaves_like "failed validation example",
                      :check_coastal_outcomes_within_project_lifetime_range, :risks,
                      I18n.t("pafs_core.validation_presenter.errors.outcome_outside_project_lifetime")
    end

    context "when outcome financial year is after the project_end_financial_year" do
      before do
        project.update(project_end_financial_year: 2027)
        create(:coastal_erosion_protection_outcomes, project: project, financial_year: 2028)
      end

      it_behaves_like "failed validation example",
                      :check_coastal_outcomes_within_project_lifetime_range, :risks,
                      I18n.t("pafs_core.validation_presenter.errors.outcome_outside_project_lifetime")
    end

    context "when multiple outcomes are outside the project lifetime range" do
      before do
        create(:coastal_erosion_protection_outcomes, project: project, financial_year: 2015)
        create(:coastal_erosion_protection_outcomes, project: project, financial_year: 2028)
      end

      it_behaves_like "failed validation example",
                      :check_coastal_outcomes_within_project_lifetime_range, :risks,
                      I18n.t("pafs_core.validation_presenter.errors.outcome_outside_project_lifetime")

      it "shows only one error message" do
        subject.check_coastal_outcomes_within_project_lifetime_range
        expect(subject.errors[:risks].count).to eq(1)
      end
    end
  end

  def make_flood_outcome(year, project_id)
    create(:flood_protection_outcomes,
           financial_year: year,
           project_id: project_id)
  end

  def make_coastal_outcome(year, project_id)
    create(:coastal_erosion_protection_outcomes,
           financial_year: year,
           project_id: project_id)
  end
end
