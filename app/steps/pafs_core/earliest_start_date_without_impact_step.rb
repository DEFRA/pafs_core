# frozen_string_literal: true

module PafsCore
  class EarliestStartDateWithoutImpactStep < BasicStep
    delegate :could_start_early?,
             :earliest_without_impact_month, :earliest_without_impact_month=,
             :earliest_without_impact_year, :earliest_without_impact_year=,
             :date_present?, :date_plausible?, :year_plausible?, :month_plausible?,
             to: :project

    validate :date_is_present_and_plausible

    private

    def step_params(params)
      params.require(:earliest_start_date_without_impact_step).permit(
        :earliest_without_impact_month, :earliest_without_impact_year
      )
    end

    def date_is_present_and_plausible
      unless date_present?("earliest_without_impact")
        errors.add(
          :earliest_without_impact_date,
          "Tell us the earliest date the project can start"
        )
      end

      unless month_plausible?("earliest_without_impact")
        errors.add(:earliest_without_impact_date, "The month must be between 1 and 12")
      end

      unless year_plausible?("earliest_without_impact")
        errors.add(:earliest_without_impact_date, "The year must be between #{PafsCore::DateUtils::VALID_YEAR_RANGE.first} and #{PafsCore::DateUtils::VALID_YEAR_RANGE.last}")
      end
    end
  end
end
