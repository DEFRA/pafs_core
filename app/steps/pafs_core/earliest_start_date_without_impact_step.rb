# frozen_string_literal: true

module PafsCore
  class EarliestStartDateWithoutImpactStep < BasicStep
    delegate :could_start_early?,
             :earliest_without_impact_month, :earliest_without_impact_month=,
             :earliest_without_impact_year, :earliest_without_impact_year=,
             :date_present?, :date_plausible?,
             to: :project

    validate :date_is_present_and_plausible

    private

    def step_params(params)
      params.require(:earliest_start_date_without_impact_step).permit(
        :earliest_without_impact_month, :earliest_without_impact_year
      )
    end

    def date_is_present_and_plausible
      unless date_present?("earliest_without_impact") &&
             date_plausible?("earliest_without_impact")
        errors.add(
          :earliest_without_impact,
          "Tell us the earliest date the project can start"
        )
      end
    end
  end
end
