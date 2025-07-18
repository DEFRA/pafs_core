# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::FinancialYearConfirmationStep do
  let(:user) { create(:user) }

  describe "#update" do
    let(:project) do
      create(:project,
             earliest_start_year: 2025,
             earliest_start_month: 4,
             project_end_financial_year: 2027,
             pending_financial_year: 2028,
             date_change_requires_confirmation: true)
    end
    let(:step) { described_class.new(project, user) }
    let(:cleaner_double) { instance_double(PafsCore::DateRangeDataCleaner, clean_data_outside_range!: true) }
    let(:end_date) { Date.new(2029, 3, 31) }

    before do
      allow(step).to receive(:financial_year_end_for).with(2028).and_return(end_date)
      allow(PafsCore::DateRangeDataCleaner).to receive(:new).and_return(cleaner_double)
    end

    it "applies the new financial year, cleans data, and resets pending flags" do
      allow(PafsCore::DateRangeDataCleaner).to receive(:new).with(project, latest_date: end_date).and_return(cleaner_double)
      allow(cleaner_double).to receive(:clean_data_outside_range!)

      step.update

      project.reload
      expect(project.project_end_financial_year).to eq(2028)
      expect(project.pending_financial_year).to be_nil
      expect(project.date_change_requires_confirmation).to be false
    end
  end
end
