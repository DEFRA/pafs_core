# frozen_string_literal: true

module PafsCore
  # A concern to provide scopes and methods for outcome models
  # that have numeric value columns.
  #
  # Expects the including model to define a constant:
  #   OUTCOME_COLUMNS = %i[column1 column2 ...].freeze
  module OutcomeScopes
    extend ActiveSupport::Concern

    included do
      scope :with_positive_values, lambda {
        where(const_get(:OUTCOME_COLUMNS).map { |col| "#{col} > 0" }.join(" OR "))
      }
    end

    def any_positive_values?
      self.class::OUTCOME_COLUMNS.reduce(0) { |sum, col| sum + send(col).to_i }.positive?
    end
  end
end
