# frozen_string_literal: true

module PafsCore
  module FinancialYearUtilities
    # Returns the start date of a financial year (April 1st)
    def self.financial_year_start_date(financial_year)
      Date.new(financial_year, 4, 1)
    end

    # Returns the end date of a financial year (March 31st of the following year)
    def self.financial_year_end_date(financial_year)
      Date.new(financial_year + 1, 3, 31)
    end

    # Returns an array of financial years from first_year to last_year (inclusive)
    def self.financial_years_between(first_year, last_year)
      (first_year..last_year).to_a
    end
  end
end
