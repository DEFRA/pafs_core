# frozen_string_literal: true

require "rails_helper"
# require_relative "./shared_step_spec"

RSpec.describe PafsCore::EarliestStartDateStep, type: :model do
  describe "attributes" do
    subject { build(:earliest_start_date_step) }

    it_behaves_like "a project step"

    it "validates that :earliest_start_month is present" do
      subject.earliest_start_month = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_start_date].first).to eq "Tell us the earliest date the project can start"
    end

    it "validates that :earliest_start_month is greater than 0" do
      subject.earliest_start_month = 0
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_start_date].first).to eq "The month must be between 1 and 12"
    end

    it "validates that :earliest_start_month is less than 13" do
      subject.earliest_start_month = 13
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_start_date].first).to eq "The month must be between 1 and 12"
    end

    it "validates that :earliest_start_year is present" do
      subject.earliest_start_year = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_start_date].first).to eq "Tell us the earliest date the project can start"
    end

    it "validates that :earliest_start_year is greater than 1999" do
      subject.earliest_start_year = 1999
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_start_date].first).to eq "The year must be between 2000 and 2100"
    end

    it "validates that :earliest_start_year is less than or equal to 2100" do
      subject.earliest_start_year = 2101
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_start_date].first).to eq "The year must be between 2000 and 2100"
    end

    it "validates that :earliest_start is in future" do
      subject.earliest_start_month = 2
      subject.earliest_start_year = 2020
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_start_date].first).to eq "You cannot enter a date in the past"
    end
  end

  describe "#update" do
    subject { create(:earliest_start_date_step, earliest_start_year: 2030, earliest_start_month: 2) }

    let(:next_year) { Time.zone.today.year + 1 }
    let(:valid_params) do
      ActionController::Parameters.new(
        { earliest_start_date_step:
          { earliest_start_month: "11", earliest_start_year: next_year.to_s } }
      )
    end
    let(:error_params) do
      ActionController::Parameters.new(
        { earliest_start_date_step:
          { earliest_start_month: "13" } }
      )
    end

    it "saves the date params when valid" do
      expect(subject.update(valid_params)).to be true
      expect(subject.earliest_start_month).to eq 11
      expect(subject.earliest_start_year).to eq next_year
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to be false
    end
  end
end
