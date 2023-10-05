# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::Camc3Presenter do
  subject { described_class.new(project: project) }

  let(:project) do
    create(
      :full_project,
      :ea_area,
      :with_no_shapefile,
      {
        project_end_financial_year: 2032,
        funding_calculator_file_name: calculator_file
      }
    )
  end
  let(:pfc_file) { Rails.root.join("..", "fixtures", "calculators", calculator_file).open }
  let(:calculator_file) do
    "v8.xlsx"
  end
  let(:funding_values) do
    [
      { year: -1, value: 2000 },
      { year: 2015, value: 200  },
      { year: 2016, value: 250  },
      { year: 2017, value: 350  },
      { year: 2018, value: 1250 },
      { year: 2019, value: 650 }
    ]
  end
  let(:funding_years) do
    [
      -1,
      2015,
      2016,
      2017,
      2018,
      2019,
      2020
    ]
  end
  let(:outcome_measurements) do
    [
      { year: -1, value: 2000 },
      { year: 2015, value: 200 },
      { year: 2016, value: 250 },
      { year: 2017, value: 350 },
      { year: 2018, value: 1250 },
      { year: 2019, value: 650 },
      { year: 2020, value: 0 },
      { year: 2021, value: 0 },
      { year: 2022, value: 0 },
      { year: 2023, value: 0 },
      { year: 2024, value: 0 },
      { year: 2025, value: 0 },
      { year: 2026, value: 0 },
      { year: 2027, value: 0 },
      { year: 2028, value: 0 },
      { year: 2029, value: 0 },
      { year: 2030, value: 0 },
      { year: 2031, value: 0 },
      { year: 2032, value: 0 }
    ]
  end
  let(:json) { subject.attributes.to_json }

  before do
    # These specs are for a "current" financial year of 2015
    Timecop.freeze(Date.new(2015, 4, 1))

    allow_any_instance_of(PafsCore::Files)
      .to receive(:fetch_funding_calculator_for)
      .with(project)
      .and_yield(pfc_file.read, calculator_file, project.funding_calculator_content_type)
  end

  after { Timecop.return }

  context "without a calculator_file" do
    before do
      allow(project).to receive(:funding_calculator_file_name).and_return(nil)
    end

    it "creates a valid json response" do
      expect(json).to match_json_schema("camc3")
    end
  end

  context "with a calculator file" do
    context "with a v9 calculator" do
      let(:calculator_file) { "v9.xlsx" }

      it "creates a valid json response" do
        expect(json).to match_json_schema("camc3")
      end
    end

    it "creates a valid json response" do
      expect(json).to match_json_schema("camc3")
    end

    describe "shapefile" do
      context "with a shapefile attached" do
        let(:shapefile) { "shapefile.zip" }
        let(:upload) { ShapefileUpload::Upload.new(project, shapefile) }
        let(:base64_shapefile) { Base64.strict_encode64(upload.data) }

        before do
          upload.perform
        end

        it "creates a valid json response" do
          expect(json).to match_json_schema("camc3")
        end

        it "renders in the generated json" do
          expect(subject.attributes).to have_key(:shapefile)
        end

        it "renders the shapefile value" do
          expect(subject.attributes[:shapefile]).to eql(base64_shapefile)
        end
      end

      context "without a shapefile attached" do
        it "creates a valid json response" do
          expect(json).to match_json_schema("camc3")
        end

        it "renders in the generated json" do
          expect(subject.attributes).to have_key(:shapefile)
        end

        it "renders the shapefile value as null" do
          expect(subject.attributes[:shapefile]).to be_nil
        end
      end
    end

    describe "urgency_details" do
      it "renders in the generated json" do
        expect(subject.attributes).to have_key(:urgency_details)
      end
    end

    describe "national_grid_reference" do
      it "renders in the generated json" do
        expect(subject.attributes).to have_key(:national_grid_reference)
      end
    end

    describe "email" do
      it "renders in the generated json" do
        expect(subject.attributes).to have_key(:email)
      end
    end

    describe "natural_flood_risk_measures" do
      it "renders in the generated json" do
        expect(subject.attributes).to have_key(:natural_flood_risk_measures)
      end

      it "contains all the natural_flood_risk_measures attributes" do
        PafsCore::NaturalFloodRiskMeasures::NATURAL_FLOOD_RISK_MEASURES.each do |nfm|
          expect(subject.attributes[:natural_flood_risk_measures]).to have_key(nfm)
        end

        expect(subject.attributes[:natural_flood_risk_measures]).to have_key(:natural_flood_risk_measures_cost)
      end
    end

    describe "secondary_risk_sources" do
      it "renders in the generated json" do
        expect(subject.attributes).to have_key(:secondary_risk_sources)
      end

      it "contains all the risk attributes" do
        PafsCore::Risks::RISKS.each do |sra|
          expect(subject.attributes[:secondary_risk_sources]).to have_key(sra)
        end
      end

      it "renders main risk as false in secondary list" do
        expect(subject.attributes[:secondary_risk_sources][project.main_risk.to_sym]).to be_falsey
      end

      it "renders risk source values" do
        PafsCore::Risks::RISKS.each do |risk|
          next if risk == project.main_risk.to_sym

          expect(subject.attributes[:secondary_risk_sources][risk]).to eql(project.send(risk))
        end
      end
    end

    shared_examples "has the expected forecast" do |outcomes_category, attribute, presenter_method = nil|
      before do
        funding_values.each do |hash|
          project.send(outcomes_category).create(
            "#{attribute}": hash[:value],
            financial_year: hash[:year]
          )
        end
      end

      it "has the forecast for #{attribute.to_s.humanize}" do
        expect(subject.send(presenter_method || attribute)).to eql(outcome_measurements)
      end
    end

    describe "#households_at_reduced_risk" do
      it_behaves_like "has the expected forecast", :flood_protection_outcomes,
                      :households_at_reduced_risk
    end

    describe "#moved_from_very_significant_and_significant_to_moderate_or_low" do
      it_behaves_like "has the expected forecast", :flood_protection_outcomes,
                      :moved_from_very_significant_and_significant_to_moderate_or_low
    end

    describe "#households_protected_from_loss_in_20_percent_most_deprived" do
      it_behaves_like "has the expected forecast", :flood_protection_outcomes,
                      :households_protected_from_loss_in_20_percent_most_deprived
    end

    describe "#non_residential_properties" do
      it_behaves_like "has the expected forecast", :flood_protection_outcomes,
                      :non_residential_properties
    end

    describe "#coastal_households_at_reduced_risk" do
      it_behaves_like "has the expected forecast", :coastal_erosion_protection_outcomes,
                      :households_at_reduced_risk,
                      :coastal_households_at_reduced_risk
    end

    describe "#coastal_households_protected_from_loss_in_20_percent_most_deprived" do
      it_behaves_like "has the expected forecast", :coastal_erosion_protection_outcomes,
                      :households_protected_from_loss_in_20_percent_most_deprived,
                      :coastal_households_protected_from_loss_in_20_percent_most_deprived
    end

    describe "#households_at_reduced_risk_2040" do
      it_behaves_like "has the expected forecast", :flood_protection2040_outcomes,
                      :households_at_reduced_risk,
                      :households_at_reduced_risk_2040
    end

    describe "#moved_from_very_significant_and_significant_to_moderate_or_low_2040" do
      it_behaves_like "has the expected forecast", :flood_protection2040_outcomes,
                      :moved_from_very_significant_and_significant_to_moderate_or_low,
                      :moved_from_very_significant_and_significant_to_moderate_or_low_2040
    end

    describe "#households_protected_from_loss_in_20_percent_most_deprived_2040" do
      it_behaves_like "has the expected forecast", :flood_protection2040_outcomes,
                      :households_protected_from_loss_in_20_percent_most_deprived,
                      :households_protected_from_loss_in_20_percent_most_deprived_2040
    end

    describe "#non_residential_properties_2040" do
      it_behaves_like "has the expected forecast", :flood_protection2040_outcomes,
                      :non_residential_properties,
                      :non_residential_properties_2040
    end
  end
end
