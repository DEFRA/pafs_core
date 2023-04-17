# frozen_string_literal: true

module PafsCore
  class EarliestStartDateStep < BasicStep
    delegate :could_start_early?,
             :earliest_start_month, :earliest_start_month=,
             :earliest_start_year, :earliest_start_year=,
             :date_present?, :date_plausible?,
             to: :project

    validate :date_is_present_and_plausible

    private

    def step_params(params)
      params.require(:earliest_start_date_step).permit(
        :earliest_start_month, :earliest_start_year
      )
    end

    def date_is_present_and_plausible
      unless date_present?("earliest_start") &&
             date_plausible?("earliest_start")
        errors.add(
          :earliest_start,
          "Tell us the earliest date the project can start"
        )
      end
    end
  end
end
