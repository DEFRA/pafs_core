# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::DateRangeDataCleaner do
  let(:project) { create(:project, earliest_start_year: 2022, earliest_start_month: 4, project_end_financial_year: 2028) }
  let(:earliest_date) { Date.new(2022, 4, 1) }
  let(:latest_date) { Date.new(2029, 3, 31) }
  let(:service) { described_class.new(project, earliest_date: earliest_date, latest_date: latest_date) }

  describe "#clean_data_outside_range!" do
    let(:checker_double) { instance_double(PafsCore::DateRangeDataChecker) }
    let(:funding_relation) { instance_double(ActiveRecord::Relation) }
    let(:flood_relation) { instance_double(ActiveRecord::Relation) }
    let(:coastal_relation) { instance_double(ActiveRecord::Relation) }

    before do
      allow(PafsCore::DateRangeDataChecker).to receive(:new).with(
        project,
        earliest_date: earliest_date,
        latest_date: latest_date
      ).and_return(checker_double)

      allow(checker_double).to receive(:relations_for_records_outside_range).and_return([
                                                                                          funding_relation,
                                                                                          flood_relation,
                                                                                          coastal_relation
                                                                                        ])

      allow(funding_relation).to receive(:delete_all)
      allow(flood_relation).to receive(:delete_all)
      allow(coastal_relation).to receive(:delete_all)
    end

    it "uses the checker to find and delete records" do
      service.clean_data_outside_range!
      expect(funding_relation).to have_received(:delete_all)
      expect(flood_relation).to have_received(:delete_all)
      expect(coastal_relation).to have_received(:delete_all)
    end

    it "returns true on success" do
      expect(service.clean_data_outside_range!).to be true
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
