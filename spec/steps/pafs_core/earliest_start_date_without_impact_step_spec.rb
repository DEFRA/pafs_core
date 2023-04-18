# frozen_string_literal: true

require "rails_helper"
# require_relative "./shared_step_spec"

RSpec.describe PafsCore::EarliestStartDateWithoutImpactStep, type: :model do
  describe "attributes" do
    subject { build(:earliest_start_date_without_impact_step) }

    it_behaves_like "a project step"

    it "validates that :earliest_without_impact_month is present" do
      subject.earliest_without_impact_month = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_without_impact_date].first).to eq "Tell us the earliest date the project can start"
    end

    it "validates that :earliest_without_impact_month is greater than 0" do
      subject.earliest_without_impact_month = 0
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_without_impact_date].first).to eq "The month must be between 1 and 12"
    end

    it "validates that :earliest_without_impact_month is less than 13" do
      subject.earliest_without_impact_month = 13
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_without_impact_date].first).to eq "The month must be between 1 and 12"
    end

    it "validates that :earliest_without_impact_year is present" do
      subject.earliest_without_impact_year = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_without_impact_date].first).to eq "Tell us the earliest date the project can start"
    end

    it "validates that :earliest_without_impact_year is greater than 1999" do
      subject.earliest_without_impact_year = 1999
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_without_impact_date].first).to eq "The year must be between 2000 and 2100"
    end

    it "validates that :earliest_without_impact_year is less than or equal to 2100" do
      subject.earliest_without_impact_year = 2101
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_without_impact_date].first).to eq "The year must be between 2000 and 2100"
    end
  end

  describe "#update" do
    subject { create(:earliest_start_date_without_impact_step) }

    let(:valid_params) do
      ActionController::Parameters.new(
        { earliest_start_date_without_impact_step:
          { earliest_without_impact_month: "11", earliest_without_impact_year: "2016" } }
      )
    end
    let(:error_params) do
      ActionController::Parameters.new(
        { earliest_start_date_without_impact_step:
          { earliest_without_impact_month: "13" } }
      )
    end

    it "saves the date params when valid" do
      expect(subject.update(valid_params)).to be true
      expect(subject.earliest_without_impact_month).to eq 11
      expect(subject.earliest_without_impact_year).to eq 2016
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to be false
    end
  end
end
