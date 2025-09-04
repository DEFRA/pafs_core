# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::EarliestStartDateConfirmationStep do
  let(:user) { create(:user) }

  describe "#update" do
    let(:project) do
      create(:project,
             earliest_start_year: 2025,
             earliest_start_month: 6,
             pending_earliest_start_year: 2026,
             pending_earliest_start_month: 4,
             date_change_requires_confirmation: true)
    end
    let(:step) { described_class.new(project, user) }
    let(:cleaner_double) { instance_double(PafsCore::DateRangeDataCleaner, clean_data_outside_range!: true) }
    let(:params) { ActionController::Parameters.new({}) }

    before do
      allow(PafsCore::DateRangeDataCleaner).to receive(:new).and_return(cleaner_double)
    end

    it "applies the new start date, cleans data, and resets pending flags" do
      new_start_date = Date.new(2026, 4, 1)
      allow(PafsCore::DateRangeDataCleaner).to receive(:new).with(project, earliest_date: new_start_date).and_return(cleaner_double)
      allow(cleaner_double).to receive(:clean_data_outside_range!)

      step.update(params)

      project.reload
      expect(project.earliest_start_year).to eq(2026)
      expect(project.earliest_start_month).to eq(4)
      expect(project.pending_earliest_start_year).to be_nil
      expect(project.pending_earliest_start_month).to be_nil
      expect(project.date_change_requires_confirmation).to be false
    end
  end
end
