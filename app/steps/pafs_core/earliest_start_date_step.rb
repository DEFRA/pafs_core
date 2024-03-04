# frozen_string_literal: true

module PafsCore
  class EarliestStartDateStep < BasicStep
    delegate :could_start_early?,
             :earliest_start_month, :earliest_start_month=,
             :earliest_start_year, :earliest_start_year=,
             :date_present?, :date_plausible?, :year_plausible?,
             :month_plausible?, :date_in_future?,
             to: :project

    validate :date_is_present_and_correct

    private

    def step_params(params)
      params.require(:earliest_start_date_step).permit(
        :earliest_start_month, :earliest_start_year
      )
    end

    def date_is_present_and_correct
      date_is_present_and_plausible
      return if errors.any?

      date_is_in_future
    end

    def date_is_present_and_plausible
      unless date_present?("earliest_start")
        errors.add(
          :earliest_start_date,
          "Tell us the earliest date the project can start"
        )
      end

      errors.add(:earliest_start_date, "The month must be between 1 and 12") unless month_plausible?("earliest_start")

      return if year_plausible?("earliest_start")

      errors.add(
        :earliest_start_date,
        "The year must be between #{PafsCore::DateUtils::VALID_YEAR_RANGE.first} " \
        "and #{PafsCore::DateUtils::VALID_YEAR_RANGE.last}"
      )
    end

    def date_is_in_future
      return unless date_present?("earliest_start") && !date_in_future?("earliest_start")

      errors.add(
        :earliest_start_date,
        "You cannot enter a date in the past"
      )
    end
  end
end
