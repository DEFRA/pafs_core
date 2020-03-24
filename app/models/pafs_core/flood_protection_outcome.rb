# frozen_string_literal: true
module PafsCore
  class FloodProtectionOutcome < ApplicationRecord
    belongs_to :project

    validates_numericality_of :households_at_reduced_risk,
                              :moved_from_very_significant_and_significant_to_moderate_or_low,
                              :households_protected_from_loss_in_20_percent_most_deprived,
                              allow_blank: true,
                              only_integer: true,
                              greater_than_or_equal_to: 0
  end
end
