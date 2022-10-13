# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ValidationPresenter do
  subject { PafsCore::ValidationPresenter.new(FactoryBot.build(:full_project)) }

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

  describe "#project_name_complete?" do
    it "always returns true" do
      expect(subject.project_name_complete?).to eq true
    end
  end

  describe "#project_type_complete?" do
    it "always returns true" do
      expect(subject.project_type_complete?).to eq true
    end
  end

  describe "#financial_year_complete?" do
    it "always returns true" do
      expect(subject.financial_year_complete?).to eq true
    end
  end

  describe "#location_complete?" do
    context "when location has been set" do
      before(:each) { subject.grid_reference = "ST 58198 72725" }

      context "when a benefit area file has been uploaded" do
        it "returns true" do
          subject.benefit_area_file_name = "my_file.jpg"
          expect(subject.location_complete?).to eq true
        end
      end

      context "when a benefit area file has not been uploaded" do
        before(:each) { subject.benefit_area_file_name = nil }

        it "returns false" do
          expect(subject.location_complete?).to eq false
        end
        it "sets an error on the project" do
          subject.location_complete?
          expect(subject.errors[:location]).to include "^Tell us the location of the project"
        end
      end
    end

    context "when location has not been set" do
      before(:each) { subject.project_location = nil }
      it "returns false" do
        expect(subject.location_complete?).to eq false
      end
      it "sets an error on the project" do
        subject.location_complete?
        expect(subject.errors[:location]).to include "^Tell us the location of the project"
      end
    end
  end

  describe "#key_dates_complete?" do
    before(:each) do
      subject.start_outline_business_case_month = 12
      subject.start_outline_business_case_year = 2016
      subject.award_contract_month = 12
      subject.award_contract_year = 2017
      subject.start_construction_month = 12
      subject.start_construction_year = 2018
      subject.ready_for_service_month = 12
      subject.ready_for_service_year = 2019
    end

    context "when the key dates are all present" do
      it "returns true" do
        expect(subject.key_dates_complete?).to eq true
      end
    end

    context "when one of the key dates is missing" do
      let(:dates) do
        %i[start_outline_business_case_month
           award_contract_month
           start_construction_month
           ready_for_service_month]
      end

      it "returns false" do
        dates.each do |date|
          m = "#{date}="
          subject.send(m, nil)
          expect(subject.key_dates_complete?).to eq false
          subject.send(m, 12)
        end
      end

      it "sets an error message" do
        dates.each do |date|
          m = "#{date}="
          subject.send(m, nil)
          subject.key_dates_complete?
          expect(subject.errors[:key_dates]).to include "^Tell us the project's important dates"
          subject.send(m, 12)
        end
      end
    end
  end

  describe "#funding_sources_complete?"

  describe "#earliest_start_complete?" do
    context "when could_start_early is nil" do
      it "returns false" do
        subject.could_start_early = nil
        expect(subject.earliest_start_complete?).to eq false
      end
    end

    context "when could_start_early is true" do
      before(:each) { subject.could_start_early = true }

      context "when earliest_start_year is present" do
        it "returns true" do
          subject.earliest_start_month = 2
          subject.earliest_start_year = 2017
          expect(subject.earliest_start_complete?).to eq true
        end
      end

      context "when earliest_start_year is not present" do
        it "returns false" do
          subject.earliest_start_month = nil
          subject.earliest_start_year = nil
          expect(subject.earliest_start_complete?).to eq false
        end
      end
    end

    context "when could_start_early is false" do
      before(:each) { subject.could_start_early = false }

      it "returns true" do
        expect(subject.earliest_start_complete?).to eq true
      end
    end
  end

  describe "#risks_complete?" do
    context "when no risks have been selected" do
      before(:each) do
        PafsCore::Risks::RISKS.each do |r|
          subject.send("#{r}=", nil)
        end
      end

      it "returns false" do
        expect(subject.risks_complete?).to eq false
      end

      it "sets an error message" do
        subject.risks_complete?
        expect(subject.errors[:risks]).to include "^Tell us the risks the project"\
          " protects against and the households benefitting."
      end
    end

    context "when risks are selected" do
      before(:each) do
        PafsCore::Risks::RISKS.each do |r|
          subject.send("#{r}=", nil)
        end
        subject.fluvial_flooding = true
        subject.flood_protection_outcomes << FactoryBot.build(:flood_protection_outcomes)
      end

      context "when a single risk is selected" do
        it "returns true" do
          expect(subject.risks_complete?).to eq true
        end
      end

      context "when multiple risks are selected" do
        before(:each) { subject.tidal_flooding = true }
        context "when a main risk is set" do
          before(:each) { subject.main_risk = "tidal_flooding" }
          it "returns true" do
            expect(subject.risks_complete?).to eq true
          end
        end

        context "when a main risk has not been set" do
          before(:each) { subject.main_risk = nil }
          it "returns false" do
            expect(subject.risks_complete?).to eq false
          end

          it "sets an error message" do
            subject.risks_complete?
            expect(subject.errors[:risks]).to include "^Tell us the risks the "\
              "project protects against and the households benefitting."
          end
        end
      end
    end
  end

  describe "#natural_flood_risk_measures_complete?" do
    context "when the natural flood risk measures have not been set" do
      before(:each) { subject.natural_flood_risk_measures_included = nil }

      it "returns false" do
        expect(subject.natural_flood_risk_measures_complete?).to eq false
      end
    end
    context "when the project includes no natural flood risk measures" do
      before(:each) { subject.natural_flood_risk_measures_included = false }

      it "returns true" do
        expect(subject.natural_flood_risk_measures_complete?).to eq true
      end
    end

    context "when the project includes natural flood risk measures" do
      before(:each) { subject.natural_flood_risk_measures_included = true }

      context "and no flood risk measures have been selected" do
        it "returns false" do
          expect(subject.natural_flood_risk_measures_complete?).to eq false
        end
      end
      context "and flood risk measures have been selected" do
        before(:each) { subject.river_restoration = true }

        context "when no cost has been provided" do
          it "returns false" do
            expect(subject.natural_flood_risk_measures_complete?).to eq false
          end
        end

        context "when the cost has been provided" do
          before(:each) { subject.natural_flood_risk_measures_cost = 123.45 }

          it "returns true" do
            expect(subject.natural_flood_risk_measures_complete?).to eq true
          end
        end
      end
    end
  end

  describe "#standard_of_protection_complete?"

  describe "#approach_complete?"

  describe "#environmental_outcomes_complete?" do
    context "when environmental_benefits is set to nil" do
      before(:each) { subject.environmental_benefits = nil }

      it "returns false" do
        expect(subject.environmental_outcomes_complete?).to eq false
      end
    end

    context "when environmental_benefits is set to false" do
      before(:each) { subject.environmental_benefits = false }

      it "returns true" do
        expect(subject.environmental_outcomes_complete?).to eq true
      end
    end

    context "when environmental_benefits is set to true" do
      before(:each) { subject.environmental_benefits = true }

      context "and no environmental benefits have been selected" do
        it "returns false" do
          expect(subject.environmental_outcomes_complete?).to eq false
        end
      end

      context "and at least one environmental benefit has been elected" do
        before(:each) do
          subject.arable_land = true
          %i[intertidal_habitat grassland woodland wet_woodland wetland_or_wet_grassland heathland ponds_lakes comprehensive_restoration partial_restoration create_habitat_watercourse].each do |benefit|
            subject.send("#{benefit}=", false)
          end
        end

        context "and the figure hasn't been provided" do
          it "returns false" do
            expect(subject.environmental_outcomes_complete?).to eq false
          end
        end

        context "and the figure has been provided" do
          before(:each) { subject.hectares_of_arable_land_lake_habitat_created_or_enhanced = 12 }

          it "returns true" do
            expect(subject.environmental_outcomes_complete?).to eq true
          end
        end
      end
    end
  end

  describe "#urgency_complete?"

  describe "#funding_calculator_complete?" do
    subject { PafsCore::ValidationPresenter.new(project) }
    let(:project) { FactoryBot.create(:full_project) }

    context "with no PFC attached" do
      it "returns false" do
        expect(subject.funding_calculator_complete?).to eq false
      end
    end

    context "with a PFC attached" do
      before(:each) do
        file_path = File.join(Rails.root, "..", "fixtures", "calculators", filename)
        file = File.open file_path
        storage = PafsCore::DevelopmentFileStorageService.new
        dest_file = File.join(project.storage_path, filename)
        storage.upload(file, dest_file)
        project.funding_calculator_file_name = filename
      end

      context "with a v8 PFC attached" do
        let(:filename) { "v8.xlsx" }

        it "returns true" do
          expect(subject.funding_calculator_complete?).to eq true
        end
      end

      context "with a 2020 v1 PFC attached" do
        let(:filename) { "v9old.xlsx" }

        it "returns false" do
          expect(subject.funding_calculator_complete?).to eq false
        end
      end

      context "withh a 2020 v2 PFC attached" do
        let(:filename) { "v9.xlsx" }

        it "returns true" do
          expect(subject.funding_calculator_complete?).to eq true
        end
      end
    end
  end

  def make_flood_outcome(year, project_id)
    FactoryBot.create(:flood_protection_outcomes,
                      financial_year: year,
                      project_id: project_id)
  end

  def make_coastal_outcome(year, project_id)
    FactoryBot.create(:coastal_erosion_protection_outcomes,
                      financial_year: year,
                      project_id: project_id)
  end
end
