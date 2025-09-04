# frozen_string_literal: true

require "rails_helper"
# require_relative "./shared_step_spec"

RSpec.describe PafsCore::EarliestStartDateStep, type: :model do
  subject(:step) { described_class.new(project, user) }

  let(:project) { create(:project, earliest_start_year: 2030, earliest_start_month: 2, project_end_financial_year: 2032) }
  let(:user) { create(:user) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :earliest_start_month is present" do
      step.earliest_start_month = nil
      expect(step.valid?).to be false
      expect(step.errors.messages[:earliest_start_date].first).to eq "Tell us the earliest date the project can start"
    end

    it "validates that :earliest_start_month is greater than 0" do
      step.earliest_start_month = 0
      expect(step.valid?).to be false
      expect(step.errors.messages[:earliest_start_date].first).to eq "The month must be between 1 and 12"
    end

    it "validates that :earliest_start_month is less than 13" do
      step.earliest_start_month = 13
      expect(step.valid?).to be false
      expect(step.errors.messages[:earliest_start_date].first).to eq "The month must be between 1 and 12"
    end

    it "validates that :earliest_start_year is present" do
      step.earliest_start_year = nil
      expect(step.valid?).to be false
      expect(step.errors.messages[:earliest_start_date].first).to eq "Tell us the earliest date the project can start"
    end

    it "validates that :earliest_start_year is greater than 1999" do
      step.earliest_start_year = 1999
      expect(step.valid?).to be false
      expect(step.errors.messages[:earliest_start_date].first).to eq "The year must be between 2000 and 2100"
    end

    it "validates that :earliest_start_year is less than or equal to 2100" do
      step.earliest_start_year = 2101
      expect(step.valid?).to be false
      expect(step.errors.messages[:earliest_start_date].first).to eq "The year must be between 2000 and 2100"
    end

    it "validates that :earliest_start is in future" do
      step.earliest_start_month = 2
      step.earliest_start_year = 2020
      expect(step.valid?).to be false
      expect(step.errors.messages[:earliest_start_date].first).to eq "You cannot enter a date in the past"
    end
  end

  describe "#update" do
    let(:checker_service) { instance_double(PafsCore::DateRangeDataChecker) }

    before do
      allow(PafsCore::DateRangeDataChecker).to receive(:new).and_return(checker_service)
    end

    context "when no data is outside the new date range" do
      let(:params) { ActionController::Parameters.new({ earliest_start_date_step: { earliest_start_month: "5", earliest_start_year: "2026" } }) }

      before { allow(checker_service).to receive(:data_outside_date_range?).and_return(false) }

      it "saves the date" do
        expect(step.update(params)).to be true
        project.reload
        expect(project.earliest_start_month).to eq 5
        expect(project.earliest_start_year).to eq 2026
      end

      it "returns false when validation fails" do
        error_params = ActionController::Parameters.new({ earliest_start_date_step: { earliest_start_month: "", earliest_start_year: "" } })
        expect(step.update(error_params)).to be false
      end

      it "does not set pending attributes" do
        step.update(params)
        project.reload
        expect(project.pending_earliest_start_month).to be_nil
        expect(project.pending_earliest_start_year).to be_nil
        expect(project.date_change_requires_confirmation).to be_falsey
      end
    end

    context "when data is outside the new date range" do
      let(:params) { ActionController::Parameters.new({ earliest_start_date_step: { earliest_start_month: "6", earliest_start_year: "2027" } }) }

      before { allow(checker_service).to receive(:data_outside_date_range?).and_return(true) }

      it "returns true" do
        expect(step.update(params)).to be true
      end

      it "sets the pending date on the project" do
        step.update(params)
        project.reload
        expect(project.pending_earliest_start_month).to eq(6)
        expect(project.pending_earliest_start_year).to eq(2027)
      end

      it "sets the date_change_requires_confirmation flag to true" do
        step.update(params)
        expect(project.reload.date_change_requires_confirmation).to be true
      end

      it "does not update the project's start date" do
        original_month = project.earliest_start_month
        original_year = project.earliest_start_year
        step.update(params)
        project.reload
        expect(project.earliest_start_month).to eq(original_month)
        expect(project.earliest_start_year).to eq(original_year)
      end
    end
  end
end
