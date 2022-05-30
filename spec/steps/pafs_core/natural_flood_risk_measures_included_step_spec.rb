# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::NaturalFloodRiskMeasuresIncludedStep, type: :model do
  subject { FactoryBot.build(:natural_flood_risk_measures_included_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :natural_flood_risk_measures_included has been set" do
      subject.natural_flood_risk_measures_included = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:natural_flood_risk_measures_included])
        .to include "You must select yes or no"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :natural_flood_risk_measures when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.natural_flood_risk_measures_included).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.natural_flood_risk_measures_included).to be false
    end

    context "when updating :natural_flood_risk_measures from true to false" do
      let(:project) do
        FactoryBot.create(
          :project,
          river_restoration: true,
          other_flood_measures: "a flood measure"
        )
      end

      subject { FactoryBot.create(:natural_flood_risk_measures_included_step, project: project) }

      it "resets the project's natural flood risk measures attributes to nil" do
        subject.update(false_params)
        project.reload

        expect(project.river_restoration).to be nil
        expect(project.other_flood_measures).to be nil
      end
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end
    end
  end

  def make_params(value)
    ActionController::Parameters.new(
      natural_flood_risk_measures_included_step: { natural_flood_risk_measures_included: value }
    )
  end
end
