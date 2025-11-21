# frozen_string_literal: true

module PafsCore
  class CoastalErosionProtectionOutcomesStep < BasicStep
    include PafsCore::FinancialYear
    include PafsCore::Outcomes
    include PafsCore::Risks

    delegate :project_type,
             :project_protects_households?,
             :reduced_risk_of_households_for_coastal_erosion?,
             :reduced_risk_of_households_for_coastal_erosion,
             :reduced_risk_of_households_for_coastal_erosion=,
             to: :project

    validate :at_least_one_value?, :values_make_sense, :sensible_number_of_houses

    validate :values?, if: :reduced_risk_of_households_for_coastal_erosion?

    def before_view(_params)
      setup_coastal_erosion_protection_outcomes
    end

    def update(params)
      @javascript_enabled = params.fetch(:js_enabled, false)
      assign_attributes(step_params(params))
      project.updated_by = user if project.respond_to?(:updated_by)
      clear_values_if_checkbox_checked
      valid? && project.save
    end

    private

    def values?
      error_found = false

      coastal_erosion_protection_outcomes.each do |outcome|
        %i[households_at_reduced_risk
           households_protected_from_loss_in_next_20_years
           households_protected_from_loss_in_20_percent_most_deprived].each do |attr|
          if outcome.send(attr).to_i.positive?
            error_found = true
            break
          end
        end
        break if error_found
      end

      return unless error_found

      errors.add(
        :base,
        "In the applicable year(s), tell us how many households moved to a lower flood risk category " \
        "(column A), OR if this does not apply select the checkbox."
      )
    end

    def values_make_sense
      b_too_big = []
      c_too_big = []
      coastal_erosion_protection_outcomes.each do |cepo|
        a = cepo.households_at_reduced_risk.to_i
        b = cepo.households_protected_from_loss_in_next_20_years.to_i
        c = cepo.households_protected_from_loss_in_20_percent_most_deprived.to_i

        b_too_big.push cepo.id if a < b
        c_too_big.push cepo.id if b < c
      end
      unless b_too_big.empty?
        errors.add(
          :base,
          "The number of households protected from loss within the next 20 years (column B) must be lower " \
          "than or equal to the number of households at a reduced risk of coastal erosion (column A)."
        )
      end

      return if c_too_big.empty?

      errors.add(
        :base,
        "The number of households in the 20% most deprived areas (column C) must be lower than or " \
        "equal to the number of households protected from loss within the next 20 years (column B)."
      )
    end

    def at_least_one_value?
      return false unless coastal_total_protected_households.zero? &&
                          !project.reduced_risk_of_households_for_coastal_erosion?

      errors.add(
        :base,
        "In the applicable year(s), tell us how many households are at a reduced risk of coastal erosion (column A), " \
        "OR if this does not apply select the checkbox."
      )
    end

    def sensible_number_of_houses
      limit = 1_000_000
      a_insensible = []
      b_insensible = []
      c_insensible = []
      d_insensible = []
      coastal_erosion_protection_outcomes.each do |cepo|
        a = cepo.households_at_reduced_risk.to_i
        b = cepo.households_protected_from_loss_in_next_20_years.to_i
        c = cepo.households_protected_from_loss_in_20_percent_most_deprived.to_i
        d = cepo.non_residential_properties.to_i

        a_insensible.push cepo.id if a > limit
        b_insensible.push cepo.id if b > limit
        c_insensible.push cepo.id if c > limit
        d_insensible.push cepo.id if d > limit
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
          "The number of households protected from loss in the next 20 years must be less than or equal to 1 million."
        )
      end

      unless c_insensible.empty?
        errors.add(
          :base,
          "The number of households protected from loss in the 20 percent most deprived areas must " \
          "be less than or equal to 1 million."
        )
      end

      return if d_insensible.empty?

      errors.add(
        :base,
        "The number of non-residential properties must be less than or equal to 1 million."
      )
    end

    def step_params(params)
      params
        .require(:coastal_erosion_protection_outcomes_step)
        .permit(:reduced_risk_of_households_for_coastal_erosion, coastal_erosion_protection_outcomes_attributes:
                                    %i[
                                      id
                                      financial_year
                                      households_at_reduced_risk
                                      households_protected_from_loss_in_next_20_years
                                      households_protected_from_loss_in_20_percent_most_deprived
                                      non_residential_properties
                                    ])
    end

    def setup_coastal_erosion_protection_outcomes
      # need to ensure the project has the right number of funding_values entries
      # for the tables
      # we need current financial year to :project_end_financial_year
      years = (Time.zone.today.uk_financial_year..project_end_financial_year)
      years.each { |y| build_missing_year(y) }
    end

    def build_missing_year(year)
      return if coastal_erosion_protection_outcomes.exists?(financial_year: year)

      coastal_erosion_protection_outcomes.build(financial_year: year)
    end

    def clear_values_if_checkbox_checked
      return unless reduced_risk_of_households_for_coastal_erosion?

      coastal_erosion_protection_outcomes.each do |outcome|
        outcome.households_at_reduced_risk = 0
        outcome.households_protected_from_loss_in_next_20_years = 0
        outcome.households_protected_from_loss_in_20_percent_most_deprived = 0
        outcome.non_residential_properties = 0
      end
    end
  end
end
