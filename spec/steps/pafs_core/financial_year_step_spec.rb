# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::FinancialYearStep, type: :model do
  describe "attributes" do
    subject(:step) { build(:financial_year_step) }

    it_behaves_like "a project step"

    it "is validates :project_end_financial_year is not empty/falsey" do
      step.project_end_financial_year = nil
      expect(step.valid?).to be false
      expect(step.errors[:project_end_financial_year]).to include(
        "Tell us the financial year when the project will stop spending funds."
      )
    end

    # validates_numericality_of doesn't work with multiple qualifiers
    # in this case :only_integer, :less_than and :greater_than
    it "validates the numericality of :project_end_financial_year" do
      step.project_end_financial_year = "abc"
      expect(step.valid?).to be false
      expect(step.errors[:project_end_financial_year]).to include(
        "Tell us the financial year when the project will stop spending funds."
      )
    end

    it "validates that :project_end_financial_year is current financial year or later" do
      step.project_end_financial_year = Time.zone.today.uk_financial_year - 1
      expect(step.valid?).to be false
      expect(step.errors[:project_end_financial_year]).to include(
        "The financial year must be in the future"
      )
    end

    it "validates that :project_end_financial_year is earlier than 2100" do
      step.project_end_financial_year = 2101
      expect(step.valid?).to be false
      expect(step.errors[:project_end_financial_year]).to include(
        "must be 2100 or earlier"
      )
    end
  end

  describe "#update" do
    subject(:step) { create(:financial_year_step) }

    let(:project) { step.project }
    let(:checker_service) { instance_double(PafsCore::DateRangeDataChecker) }

    let(:params) { ActionController::Parameters.new({ financial_year_step: { project_end_financial_year: "2028" } }) }
    let(:error_params) { ActionController::Parameters.new({ financial_year_step: { project_end_financial_year: "1983" } }) }

    before do
      allow(PafsCore::DateRangeDataChecker).to receive(:new).and_return(checker_service)
    end

    context "when no data is outside the new date range" do
      before { allow(checker_service).to receive(:data_outside_date_range?).and_return(false) }

      it "saves the :project_end_financial_year if valid" do
        expect(step.update(params)).to be true
        expect(project.reload.project_end_financial_year).to eq 2028
      end

      it "returns false when validation fails" do
        expect(step.update(error_params)).to be false
      end

      it "does not set pending attributes" do
        step.update(params)
        project.reload
        expect(project.pending_financial_year).to be_nil
        expect(project.date_change_requires_confirmation).to be_nil
      end
    end

    context "when data is outside the new date range" do
      before { allow(checker_service).to receive(:data_outside_date_range?).and_return(true) }

      it "returns true" do
        expect(step.update(params)).to be true
      end

      it "sets the pending financial year on the project" do
        step.update(params)
        expect(project.reload.pending_financial_year).to eq(2028)
      end

      it "sets the date_change_requires_confirmation flag to true" do
        step.update(params)
        expect(project.reload.date_change_requires_confirmation).to be true
      end

      it "does not update the project's financial year" do
        original_year = project.project_end_financial_year
        step.update(params)
        expect(project.reload.project_end_financial_year).to eq(original_year)
      end
    end
  end

  describe "#financial_year_options" do
    subject { build(:financial_year_step) }

    it "returns the correct set of financial year options" do
      current_financial_year = Time.zone.today.uk_financial_year
      expect(subject.financial_year_options).to eq current_financial_year..(current_financial_year + 5)
    end
  end

  describe "#before_view" do
    subject(:step) { create(:financial_year_step, pending_financial_year: 2025, date_change_requires_confirmation: true) }

    context "with a PafsCore::Project" do
      it "sets the project's pending_financial_year value to nil" do
        expect { subject.before_view({}) }.to change(subject, :pending_financial_year).to(nil)
      end

      it "sets the project's date_change_requires_confirmation values to nil" do
        expect { subject.before_view({}) }.to change(subject, :date_change_requires_confirmation).to(nil)
      end
    end

    context "with a PafsCore::Bootstrap" do
      it { expect { subject.before_view({}) }.not_to raise_error }
    end
  end
end
