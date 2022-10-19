# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::FloodProtectionOutcomes2040SummaryStep, type: :model do
  before do
    @project = create(:project)
    @project.project_end_financial_year = 2022
    @project.fluvial_flooding = true
    @fpo1 = create(:flood_protection2040_outcomes, financial_year: 2017, project_id: @project.id)
    @fpo2 = create(:flood_protection2040_outcomes, financial_year: 2020, project_id: @project.id)
    @fpo3 = create(:flood_protection2040_outcomes, financial_year: 2030, project_id: @project.id)
    @project.flood_protection2040_outcomes << @fpo1
    @project.flood_protection2040_outcomes << @fpo2
    @project.flood_protection2040_outcomes << @fpo3

    @project.save
  end

  describe "#current_flood_protection_outcomes" do
    subject { PafsCore::FloodProtectionOutcomesSummaryStep.new @project }

    it "returns only flood_protection_outcomes from before the project end financial year" do
      expect(subject.current_flood_protection2040_outcomes).to include(@fpo1, @fpo2)
      expect(subject.current_flood_protection2040_outcomes).not_to include(@fpo3)
    end
  end

  describe "#update" do
    subject { described_class.new @project }

    it "returns true" do
      expect(subject.update({})).to be true
    end
  end

  describe "#total_fpo_for" do
    subject { described_class.new @project }

    it "returns the correct totals for the three columns" do
      expect(subject.total_fpo2040_for(:households_at_reduced_risk)).to eq 200
      expect(subject.total_fpo2040_for(:moved_from_very_significant_and_significant_to_moderate_or_low)).to eq 100
      expect(subject.total_fpo2040_for(:households_protected_from_loss_in_20_percent_most_deprived)).to eq 50
    end
  end
end
