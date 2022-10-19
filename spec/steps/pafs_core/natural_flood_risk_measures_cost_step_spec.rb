# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::NaturalFloodRiskMeasuresCostStep, type: :model do
  describe "attributes" do
    subject { build(:natural_flood_risk_measures_cost_step) }

    it_behaves_like "a project step"

    it "validates that the cost has been entered" do
      subject.natural_flood_risk_measures_cost = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include "You must include a total cost for your flood risk measures"
    end
  end
end
