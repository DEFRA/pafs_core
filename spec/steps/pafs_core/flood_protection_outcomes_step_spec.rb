# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::FloodProtectionOutcomesStep, type: :model do
  before do
    Timecop.freeze(Date.new(2015, 4, 1))

    @project = create(:project)
    @project.project_end_financial_year = 2027
    @project.fluvial_flooding = true
    @fpo1 = create(:flood_protection_outcomes, financial_year: 2017, project_id: @project.id)
    @fpo2 = create(:flood_protection_outcomes, financial_year: 2020, project_id: @project.id)
    @fpo3 = create(:flood_protection_outcomes, financial_year: 2030, project_id: @project.id)
    @project.flood_protection_outcomes << @fpo1
    @project.flood_protection_outcomes << @fpo2
    @project.flood_protection_outcomes << @fpo3

    @project.save
  end

  after { Timecop.return }

  describe "attributes" do
    subject { described_class.new @project }

    it_behaves_like "a project step"

    it "validates that value C is smaller than B" do
      subject.flood_protection_outcomes.build(financial_year: 2020,
                                              households_at_reduced_risk: 100,
                                              moved_from_very_significant_and_significant_to_moderate_or_low: 50,
                                              households_protected_from_loss_in_20_percent_most_deprived: 100)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include(
        "The number of households in the 20% most deprived areas (column C) must be lower than " \
        "or equal to the number of households moved from very significant " \
        "or significant to the moderate or low flood risk category (column B)."
      )
    end

    it "validates that value D is smaller than B" do
      subject.flood_protection_outcomes.build(financial_year: 2020,
                                              households_at_reduced_risk: 100,
                                              moved_from_very_significant_and_significant_to_moderate_or_low: 50,
                                              households_protected_through_plp_measures: 100)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include(
        "The number of households that are protected through Property Level Protection " \
        "(PLP) measures (column D) must be lower than or equal to " \
        "the number of households moved from very significant " \
        "or significant to the moderate or low flood risk category (column B)."
      )
    end

    it "validates that value B is smaller than A" do
      subject.flood_protection_outcomes.build(financial_year: 2020,
                                              households_at_reduced_risk: 100,
                                              moved_from_very_significant_and_significant_to_moderate_or_low: 200)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include(
        "The number of households moved from very significant or significant to " \
        "moderate or low flood risk category (column B) must be lower than or equal " \
        "to the number of households moved to a lower flood risk category (column A)."
      )
    end

    it "validates that there is at least one A value" do
      @project.flood_protection_outcomes = []
      @project.save
      subject.flood_protection_outcomes.build(financial_year: 2020,
                                              households_at_reduced_risk: 0)

      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include(
        "In the applicable year(s), tell us how many households moved to a lower flood " \
        "risk category (column A), OR if this does not apply select the checkbox."
      )
    end

    it "validates that number of households is less than or equal to 1 million" do
      subject.flood_protection_outcomes.build(financial_year: 2020,
                                              households_at_reduced_risk: 1_000_001,
                                              moved_from_very_significant_and_significant_to_moderate_or_low: 1_000_001,
                                              households_protected_from_loss_in_20_percent_most_deprived: 1_000_001)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include(
        "The number of households at reduced risk must be less than or equal to 1 million."
      )
      expect(subject.errors.messages[:base]).to include(
        "The number of households moved from very significant and significant to moderate or low must be " \
        "less than or equal to 1 million."
      )
      expect(subject.errors.messages[:base]).to include(
        "The number of households protected from loss in the 20 percent most deprived must be " \
        "less than or equal to 1 million."
      )
    end
  end

  describe "#update" do
    subject { described_class.new @project }

    let(:params) do
      ActionController::Parameters.new(
        { flood_protection_outcomes_step:
          { flood_protection_outcomes_attributes:
            [{ financial_year: 2020,
               households_at_reduced_risk: 2000,
               moved_from_very_significant_and_significant_to_moderate_or_low: 1000,
               households_protected_from_loss_in_20_percent_most_deprived: 500 }] } }
      )
    end

    let(:checkbox_params) do
      ActionController::Parameters.new(
        { flood_protection_outcomes_step:
          { reduced_risk_of_households_for_floods: "1",
            flood_protection_outcomes_attributes:
            [{ financial_year: 2020,
               households_at_reduced_risk: 2000,
               moved_from_very_significant_and_significant_to_moderate_or_low: 1000,
               households_protected_from_loss_in_20_percent_most_deprived: 500,
               households_protected_through_plp_measures: 300,
               non_residential_properties: 100 }] } }
      )
    end

    let(:error_params) do
      ActionController::Parameters.new(
        { flood_protection_outcomes_step:
          { flood_protection_outcomes_attributes:
            [{ financial_year: 2020,
               households_at_reduced_risk: 1000,
               moved_from_very_significant_and_significant_to_moderate_or_low: 2000,
               households_protected_from_loss_in_20_percent_most_deprived: 5000 }] } }
      )
    end

    context "when params are invalid" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not save the changes" do
        expect { subject.update(error_params) }.not_to change { subject.flood_protection_outcomes.count }
      end
    end

    context "when params are valid" do
      it "saves the changes" do
        expect { subject.update(params) }.to change { subject.flood_protection_outcomes.count }.by(1)
        flood_protection_outcome = subject.flood_protection_outcomes.last
        expect(flood_protection_outcome.financial_year).to eq 2020
        expect(flood_protection_outcome.households_at_reduced_risk).to eq 2000
        expect(flood_protection_outcome.moved_from_very_significant_and_significant_to_moderate_or_low).to eq 1000
        expect(flood_protection_outcome.households_protected_from_loss_in_20_percent_most_deprived).to eq 500
      end

      it "returns true" do
        expect(subject.update(params)).to be true
      end
    end

    context "when the 'no properties affected' checkbox is checked" do
      it "sets all values to zero" do
        subject.update(params)

        subject.update(checkbox_params)

        subject.flood_protection_outcomes.each do |outcome|
          expect(outcome.households_at_reduced_risk).to eq 0
          expect(outcome.moved_from_very_significant_and_significant_to_moderate_or_low).to eq 0
          expect(outcome.households_protected_from_loss_in_20_percent_most_deprived).to eq 0
          expect(outcome.households_protected_through_plp_measures).to eq 0
          expect(outcome.non_residential_properties).to eq 0
        end
      end
    end
  end

  describe "#current_flood_protection_outcomes" do
    subject { described_class.new @project }
    # subject.project.coastal_erosion_protection_outcomes << [@cepo1, @cepo2, @cepo3]

    it "includes the coastal erosion protection outcomes before the project end financial year" do
      expect(subject.current_flood_protection_outcomes).to include(@fpo1, @fpo2)
    end

    it "does not include the coastal erosion protection outcomes after the project end financial year" do
      expect(subject.current_flood_protection_outcomes).not_to include(@fpo3)
    end
  end

  describe "#before_view" do
    subject { described_class.new @project }

    it "builds flood_protection_outcome records for any missing years" do
      # test start year is 2015
      # project_end_financial_year = 2027
      # values are initially populated for 2017, 2020, 2030
      # so expect years to be added for 2015, 2016, 2018, 2019, 2021, 2022, 2023, 2024, 2025, 2026, 2027
      expect { subject.before_view({}) }.to change { subject.flood_protection_outcomes.length }.by(11)
    end
  end
end
