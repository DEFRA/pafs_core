# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::FinancialYearUtilities do
  describe ".financial_year_start_date" do
    it "returns April 1st of the given financial year" do
      expect(described_class.financial_year_start_date(2022)).to eq(Date.new(2022, 4, 1))
      expect(described_class.financial_year_start_date(2030)).to eq(Date.new(2030, 4, 1))
    end
  end

  describe ".financial_year_end_date" do
    it "returns March 31st of the following year" do
      expect(described_class.financial_year_end_date(2022)).to eq(Date.new(2023, 3, 31))
      expect(described_class.financial_year_end_date(2030)).to eq(Date.new(2031, 3, 31))
    end
  end

  describe ".financial_years_between" do
    it "returns an array of years from first_year to last_year (inclusive)" do
      expect(described_class.financial_years_between(2022, 2025)).to eq([2022, 2023, 2024, 2025])
      expect(described_class.financial_years_between(2030, 2030)).to eq([2030])
    end

    it "returns an empty array when last_year is less than first_year" do
      expect(described_class.financial_years_between(2025, 2022)).to eq([])
    end
  end
end
