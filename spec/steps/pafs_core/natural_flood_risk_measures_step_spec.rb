# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::NaturalFloodRiskMeasuresStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:natural_flood_risk_measures_step) }

    it_behaves_like "a project step"

    it "validates that at least one natural flood risk measure is selected" do
      subject.river_restoration = false
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include "The project must include at least one flood risk measure"
    end
  end

  describe "#update" do
    subject { FactoryBot.create(:natural_flood_risk_measures_step) }
    let(:params) do
      ActionController::Parameters.new(
        { natural_flood_risk_measures_step: {
          floodplain_restoration: "1",
          other_flood_measures: "Another flood measure"
        } }
      )
    end

    let(:error_params) do
      ActionController::Parameters.new(
        { natural_flood_risk_measures_step: {
          river_restoration: "0"
        } }
      )
    end

    it "saves the state of valid params" do
      expect(subject.update(params)).to be true
      expect(subject.floodplain_restoration).to be true
      expect(subject.other_flood_measures).to eq "Another flood measure"
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end
end
