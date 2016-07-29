# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class FloodProtectionOutcomesStep < BasicStep
    include PafsCore::Outcomes, PafsCore::Risks, PafsCore::FinancialYear
    delegate :project_end_financial_year,
             :project_type,
             :project_protects_households?,
             to: :project

    validate :values_make_sense, :at_least_one_value

    # def disabled?
    #   !(protects_against_flooding? && !project_end_financial_year.nil? && project_protects_households?)
    # end

    def before_view
      setup_flood_protection_outcomes
    end

    private
    def values_make_sense
      b_too_big = []
      c_too_big = []
      flood_protection_outcomes.each do |fpo|
        a = fpo.households_at_reduced_risk.to_i
        b = fpo.moved_from_very_significant_and_significant_to_moderate_or_low.to_i
        c = fpo.households_protected_from_loss_in_20_percent_most_deprived.to_i

        b_too_big.push fpo.id if a < b
        c_too_big.push fpo.id if b < c
      end
      errors.add(:base, "B must be smaller than or equal to A") if !b_too_big.empty?
      errors.add(:base, "C must be smaller than or equal to B") if !c_too_big.empty?
    end

    def at_least_one_value
      errors.add(:base, "There must be at least one value in column A") if total_protected_households.zero?
    end

    def total_protected_households
      flood_protection_outcomes.map(&:households_at_reduced_risk).compact.sum
    end

    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:flood_protection_outcomes_step)
                                  .permit(flood_protection_outcomes_attributes:
                                    [
                                      :id,
                                      :financial_year,
                                      :households_at_reduced_risk,
                                      :moved_from_very_significant_and_significant_to_moderate_or_low,
                                      :households_protected_from_loss_in_20_percent_most_deprived
                                    ])
    end

    def setup_flood_protection_outcomes
      # need to ensure the project has the right number of funding_values entries
      # for the tables
      # we need at least:
      #   previous years
      #   current financial year to :project_end_financial_year
      years = [-1]
      years.concat((current_financial_year..project_end_financial_year).to_a)
      years.each { |y| build_missing_year(y) }
    end

    def build_missing_year(year)
      if !flood_protection_outcomes.exists?(financial_year: year)
        flood_protection_outcomes.build(financial_year: year)
      end
    end
  end
end
