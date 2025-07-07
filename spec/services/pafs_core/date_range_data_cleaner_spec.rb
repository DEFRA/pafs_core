# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::DateRangeDataCleaner do
  let(:project) { create(:project, earliest_start_year: 2022, earliest_start_month: 4, project_end_financial_year: 2028) }
  let(:earliest_date) { Date.new(2022, 4, 1) }
  let(:latest_date) { Date.new(2029, 3, 31) }
  let(:service) { described_class.new(project, earliest_date: earliest_date, latest_date: latest_date) }

  describe "#clean_data_outside_range!" do
    # Data that should be deleted (outside date range)
    let!(:funding_outside_before) { create(:funding_value, project: project, financial_year: 2021) }
    let!(:funding_outside_after) { create(:funding_value, project: project, financial_year: 2030) }
    let!(:flood_outcome_outside) { create(:flood_protection_outcomes, project: project, financial_year: 2021) }
    let!(:coastal_outcome_outside) { create(:coastal_erosion_protection_outcomes, project: project, financial_year: 2030) }

    # Data that should be kept (within date range)
    let!(:funding_inside_start) { create(:funding_value, project: project, financial_year: 2022) }
    let!(:funding_inside_end) { create(:funding_value, project: project, financial_year: 2028) }
    let!(:flood_outcome_inside) { create(:flood_protection_outcomes, project: project, financial_year: 2025) }
    let!(:coastal_outcome_inside) { create(:coastal_erosion_protection_outcomes, project: project, financial_year: 2027) }

    # Shared setup for all examples in this context
    let!(:run_cleaner) { service.clean_data_outside_range! }

    it "returns true when successful" do
      expect(run_cleaner).to be true
    end

    context "with funding values" do
      it "verifies initial count of funding values" do
        expect(project.reload.funding_values.count).to eq(2)
      end

      it "deletes funding values before the date range" do
        expect(project.funding_values.exists?(id: funding_outside_before.id)).to be false
      end

      it "deletes funding values after the date range" do
        expect(project.funding_values.exists?(id: funding_outside_after.id)).to be false
      end

      it "keeps funding values at the start of date range" do
        expect(project.funding_values.exists?(id: funding_inside_start.id)).to be true
      end

      it "keeps funding values at the end of date range" do
        expect(project.funding_values.exists?(id: funding_inside_end.id)).to be true
      end
    end

    context "with flood protection outcomes" do
      it "verifies final count of flood protection outcomes" do
        expect(project.reload.flood_protection_outcomes.count).to eq(1)
      end

      it "deletes flood protection outcomes outside date range" do
        expect(project.flood_protection_outcomes.exists?(id: flood_outcome_outside.id)).to be false
      end

      it "keeps flood protection outcomes inside date range" do
        expect(project.flood_protection_outcomes.exists?(id: flood_outcome_inside.id)).to be true
      end
    end

    context "with coastal erosion protection outcomes" do
      it "verifies final count of coastal erosion protection outcomes" do
        expect(project.reload.coastal_erosion_protection_outcomes.count).to eq(1)
      end

      it "deletes coastal protection outcomes outside date range" do
        expect(project.coastal_erosion_protection_outcomes.exists?(id: coastal_outcome_outside.id)).to be false
      end

      it "keeps coastal protection outcomes inside date range" do
        expect(project.coastal_erosion_protection_outcomes.exists?(id: coastal_outcome_inside.id)).to be true
      end
    end

    context "when a transaction fails" do
      before do
        allow(ActiveRecord::Base).to receive(:transaction).and_raise(StandardError, "DB Error")
        allow(Rails.logger).to receive(:error)
      end

      it "logs the error and returns false" do
        expect(service.clean_data_outside_range!).to be false
        expect(Rails.logger).to have_received(:error).with(/Error cleaning data outside date range: DB Error/)
      end
    end
  end
end
