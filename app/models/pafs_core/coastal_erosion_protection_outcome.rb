# frozen_string_literal: true

module PafsCore
  class CoastalErosionProtectionOutcome < ApplicationRecord
    OUTCOME_COLUMNS = %i[
      households_at_reduced_risk
      households_protected_from_loss_in_next_20_years
      households_protected_from_loss_in_20_percent_most_deprived
      non_residential_properties
    ].freeze

    include PafsCore::OutcomeData

    belongs_to :project

    def financial_year_in_range?(year_from, year_to)
      return false if financial_year.nil?

      financial_year.between?(year_from, year_to)
    end
  end
end
