# frozen_string_literal: true

module PafsCore
  class EarliestStartDateWithGiaStep < BasicStep
    delegate :could_start_early?,
             :earliest_with_gia_month, :earliest_with_gia_month=,
             :earliest_with_gia_year, :earliest_with_gia_year=,
             :date_present?, :date_plausible?, :year_plausible?, :month_plausible?,
             to: :project

    validate :date_is_present_and_plausible

    private

    def step_params(params)
      params.require(:earliest_start_date_with_gia_step).permit(
        :earliest_with_gia_month, :earliest_with_gia_year
      )
    end

    def date_is_present_and_plausible
      unless date_present?("earliest_with_gia")
        errors.add(
          :earliest_with_gia_date,
          "Tell us the earliest date the project can start"
        )
      end

      unless month_plausible?("earliest_with_gia")
        errors.add(:earliest_with_gia_date, "The month must be between 1 and 12")
      end

      return if year_plausible?("earliest_with_gia")

      errors.add(:earliest_with_gia_date,
                 "The year must be between #{PafsCore::DateUtils::VALID_YEAR_RANGE.first} and #{PafsCore::DateUtils::VALID_YEAR_RANGE.last}")
    end
  end
end
