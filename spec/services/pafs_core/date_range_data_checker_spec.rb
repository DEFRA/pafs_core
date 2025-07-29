# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::DateRangeDataChecker do
  subject(:checker) { described_class.new(project, earliest_date: earliest_date, latest_date: latest_date) }

  let(:project) { create(:project, fcerm_gia: true) }
  let(:earliest_date) { Date.new(2025, 4, 1) }
  let(:latest_date) { Date.new(2028, 3, 31) }

  describe "#data_outside_date_range?" do
    context "when all data is within the date range" do
      before do
        create(:funding_value, project: project, financial_year: 2026, fcerm_gia: 100)
        create(:flood_protection_outcomes, project: project, financial_year: 2027, households_at_reduced_risk: 10)
      end

      it "returns false" do
        expect(checker.data_outside_date_range?).to be false
      end
    end

    context "when there is no data" do
      it "returns false" do
        expect(checker.data_outside_date_range?).to be false
      end
    end

    context "when funding values are outside the date range" do
      before do
        create(:funding_value, project: project, financial_year: 2024, fcerm_gia: 100) # Before
        create(:funding_value, project: project, financial_year: 2029, fcerm_gia: 100) # After
      end

      it "returns true" do
        expect(checker.data_outside_date_range?).to be true
      end
    end

    context "when flood protection outcomes are outside the date range" do
      before do
        create(:flood_protection_outcomes, project: project, financial_year: 2024, households_at_reduced_risk: 10)
      end

      it "returns true" do
        expect(checker.data_outside_date_range?).to be true
      end
    end

    context "when coastal erosion outcomes are outside the date range" do
      before do
        create(:coastal_erosion_protection_outcomes, project: project, financial_year: 2029,
                                                     households_at_reduced_risk: 10)
      end

      it "returns true" do
        expect(checker.data_outside_date_range?).to be true
      end
    end

    context "when flood protection 2040 outcomes are outside the date range" do
      before do
        create(:flood_protection2040_outcomes, project: project, financial_year: 2024, households_at_reduced_risk: 10)
      end

      it "returns true" do
        expect(checker.data_outside_date_range?).to be true
      end
    end

    context "when using default dates from the project" do
      subject(:checker) { described_class.new(project) }

      let(:project) do
        create(:project, fcerm_gia: true, earliest_start_year: 2025, earliest_start_month: 4,
                         project_end_financial_year: 2027)
      end

      before do
        # This should be outside the project's default range (2025-2027)
        create(:funding_value, project: project, financial_year: 2029, fcerm_gia: 100)
      end

      it "returns true" do
        expect(checker.data_outside_date_range?).to be true
      end
    end
  end

  describe "#relations_for_records_outside_range" do
    let!(:funding_value) { create(:funding_value, project: project, financial_year: 2029, fcerm_gia: 100) }
    let!(:flood_outcome) do
      create(:flood_protection_outcomes, project: project, financial_year: 2024, households_at_reduced_risk: 10)
    end
    let!(:flood_2040_outcome) do
      create(:flood_protection2040_outcomes, project: project, financial_year: 2024, households_at_reduced_risk: 10)
    end

    it "returns the correct ActiveRecord relations" do
      relations = checker.relations_for_records_outside_range
      expect(relations[0].first).to eq(funding_value)
      expect(relations[1].first).to eq(flood_outcome)
      expect(relations[2].first).to eq(flood_2040_outcome)
      expect(relations[3]).to be_empty
    end

    it "memoizes the result" do
      allow(project).to receive(:funding_values).and_call_original
      checker.relations_for_records_outside_range
      checker.relations_for_records_outside_range
      expect(project).to have_received(:funding_values).once
    end
  end
end
