# frozen_string_literal: true

module PafsCore
  class CoastalErosionProtectionOutcome < ApplicationRecord
    belongs_to :project

    validates :households_at_reduced_risk,
              :households_protected_from_loss_in_next_20_years,
              :households_protected_from_loss_in_20_percent_most_deprived,
              numericality: { allow_blank: true,
                              only_integer: true,
                              greater_than_or_equal_to: 0 }

    def any_positive_values?
      all_outcome_columns = %i[
        households_at_reduced_risk
        households_protected_from_loss_in_next_20_years
        households_protected_from_loss_in_20_percent_most_deprived
        non_residential_properties
      ]
      all_outcome_columns.reduce(0) { |sum, aoc| sum + send(aoc).to_i }.positive?
    end

    def financial_year_in_range?(year_from, year_to)
      return false if financial_year.nil?

      financial_year.between?(year_from, year_to)
    end
  end
end
