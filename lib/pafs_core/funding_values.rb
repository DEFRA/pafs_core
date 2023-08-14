# frozen_string_literal: true

module PafsCore
  module FundingValues
    delegate :project_end_financial_year,
             :funding_values,
             :funding_values=,
             :funding_values_attributes=,
             to: :project

    def build_missing_year(year)
      funding_values.build(financial_year: year) unless funding_values.exists?(financial_year: year)
    end

    def setup_funding_values
      # need to ensure the project has the right number of funding_values entries
      # for the tables
      # we need current financial year to :project_end_financial_year
      years = (Time.zone.today.uk_financial_year..project_end_financial_year)
      years.each { |y| build_missing_year(y) }
    end
  end
end
