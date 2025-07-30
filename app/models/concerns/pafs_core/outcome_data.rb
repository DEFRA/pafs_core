# frozen_string_literal: true

module PafsCore
  # A concern to provide scopes and validations for outcome models
  # that have numeric value columns.
  #
  # Expects the including model to define a constant:
  #   OUTCOME_COLUMNS = %i[column1 column2 ...].freeze
  module OutcomeData
    extend ActiveSupport::Concern

    included do
      validates(*const_get(:OUTCOME_COLUMNS), numericality: { allow_blank: true,
                                                              only_integer: true,
                                                              greater_than_or_equal_to: 0 })

      scope :with_positive_values, lambda {
        where(const_get(:OUTCOME_COLUMNS).map { |col| "#{col} > 0" }.join(" OR "))
      }
    end
  end
end
