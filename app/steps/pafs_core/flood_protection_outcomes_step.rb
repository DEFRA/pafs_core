# frozen_string_literal: true

module PafsCore
  class FloodProtectionOutcomesStep < BasicStep
    include PafsCore::FinancialYear
    include PafsCore::Risks
    include PafsCore::Outcomes
    delegate :project_end_financial_year,
             :project_type,
             :project_protects_households?,
             :reduced_risk_of_households_for_floods?,
             :reduced_risk_of_households_for_floods,
             :reduced_risk_of_households_for_floods=,
             to: :project

    validate :at_least_one_value?, :values_make_sense, :sensible_number_of_houses

    validate :values?, if: :reduced_risk_of_households_for_floods?

    def before_view(_params)
      setup_flood_protection_outcomes
    end

    def update(params)
      @javascript_enabled = params.fetch(:js_enabled, false)
      assign_attributes(step_params(params))
      project.updated_by = user if project.respond_to?(:updated_by)
      clear_values_if_checkbox_checked
      valid? && project.save
    end

    private

    def clear_values_if_checkbox_checked
      return unless reduced_risk_of_households_for_floods?

      flood_protection_outcomes.each do |outcome|
        outcome.households_at_reduced_risk = 0
        outcome.moved_from_very_significant_and_significant_to_moderate_or_low = 0
        outcome.households_protected_from_loss_in_20_percent_most_deprived = 0
        outcome.households_protected_through_plp_measures = 0
        outcome.non_residential_properties = 0
      end
    end

    def values?
      values = flood_protection_outcomes.collect do |outcome|
        next unless outcome.households_at_reduced_risk.present? ||
                    outcome.moved_from_very_significant_and_significant_to_moderate_or_low.present? ||
                    outcome.households_protected_from_loss_in_20_percent_most_deprived.present?

        true
      end.compact!

      return false unless values.present? && values.include?(true)

      errors.add(
        :base,
        "In the applicable year(s), tell us how many households moved to a lower flood risk category (column A), " \
        "OR if this does not apply select the checkbox."
      )
    end

    def values_make_sense
      b_too_big = []
      c_too_big = []
      d_too_big = []
      flood_protection_outcomes.each do |fpo|
        a = fpo.households_at_reduced_risk.to_i
        b = fpo.moved_from_very_significant_and_significant_to_moderate_or_low.to_i
        c = fpo.households_protected_from_loss_in_20_percent_most_deprived.to_i
        d = fpo.households_protected_through_plp_measures.to_i

        b_too_big.push fpo.id if a < b
        c_too_big.push fpo.id if b < c
        d_too_big.push fpo.id if b < d
      end
      unless b_too_big.empty?
        errors.add(
          :base,
          "The number of households moved from very significant or significant to " \
          "moderate or low flood risk category (column B) must be lower than or equal " \
          "to the number of households moved to a lower flood risk category (column A)."
        )
      end

      unless c_too_big.empty?
        errors.add(
          :base,
          "The number of households in the 20% most deprived areas (column C) must be lower than or equal " \
          "to the number of households moved from very significant " \
          "or significant to the moderate or low flood risk category (column B)."
        )
      end

      return if d_too_big.empty?

      errors.add(
        :base,
        "The number of households that are protected through Property Level Protection (PLP) " \
        "measures (column D) must be lower than or equal to " \
        "the number of households moved from very significant " \
        "or significant to the moderate or low flood risk category (column B)."
      )
    end

    def at_least_one_value?
      return false unless flooding_total_protected_households.zero? && !project.reduced_risk_of_households_for_floods?

      errors.add(
        :base,
        "In the applicable year(s), tell us how many households moved to a lower flood risk category (column A), " \
        "OR if this does not apply select the checkbox."
      )
    end

    def sensible_number_of_houses
      limit = 1_000_000
      a_insensible = []
      b_insensible = []
      c_insensible = []
      d_insensible = []
      e_insensible = []
      flood_protection_outcomes.each do |fpo|
        a = fpo.households_at_reduced_risk.to_i
        b = fpo.moved_from_very_significant_and_significant_to_moderate_or_low.to_i
        c = fpo.households_protected_from_loss_in_20_percent_most_deprived.to_i
        d = fpo.households_protected_through_plp_measures.to_i
        e = fpo.non_residential_properties.to_i

        a_insensible.push fpo.id if a > limit
        b_insensible.push fpo.id if b > limit
        c_insensible.push fpo.id if c > limit
        d_insensible.push fpo.id if d > limit
        e_insensible.push fpo.id if e > limit
      end

      unless a_insensible.empty?
        errors.add(
          :base,
          "The number of households at reduced risk must be less than or equal to 1 million."
        )
      end

      unless b_insensible.empty?
        errors.add(
          :base,
          "The number of households moved from very significant and significant to moderate or low must be " \
          "less than or equal to 1 million."
        )
      end

      unless c_insensible.empty?
        errors.add(
          :base,
          "The number of households protected from loss in the 20 percent most deprived must be " \
          "less than or equal to 1 million."
        )
      end

      unless d_insensible.empty?
        errors.add(
          :base,
          "The number of households protected through Property Level Protection (PLP) measures must be " \
          "less than or equal to 1 million."
        )
      end

      return if e_insensible.empty?

      errors.add(
        :base,
        "The number of non-residential properties must be less than or equal to 1 million."
      )
    end

    def step_params(params)
      params
        .require(:flood_protection_outcomes_step)
        .permit(:reduced_risk_of_households_for_floods, flood_protection_outcomes_attributes:
                                    %i[
                                      id
                                      financial_year
                                      households_at_reduced_risk
                                      moved_from_very_significant_and_significant_to_moderate_or_low
                                      households_protected_from_loss_in_20_percent_most_deprived
                                      households_protected_through_plp_measures
                                      non_residential_properties
                                    ])
    end

    def setup_flood_protection_outcomes
      # need to ensure the project has the right number of funding_values entries
      # for the tables
      # we need current financial year to :project_end_financial_year
      years = (Time.zone.today.uk_financial_year..project_end_financial_year)
      years.each { |y| build_missing_year(y) }
    end

    def build_missing_year(year)
      return if flood_protection_outcomes.exists?(financial_year: year)

      flood_protection_outcomes.build(financial_year: year)
    end
  end
end
