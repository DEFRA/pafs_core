# frozen_string_literal: true

module PafsCore
  class StartOutlineBusinessCaseDateStep < BasicStep
    delegate :start_outline_business_case_month, :start_outline_business_case_month=,
             :start_outline_business_case_year, :start_outline_business_case_year=,
             :date_present?, :date_plausible?, :date_in_future?,
             to: :project

    validate :date_is_present_and_correct

    private

    def step_params(params)
      params
        .require(:start_outline_business_case_date_step)
        .permit(:start_outline_business_case_month, :start_outline_business_case_year)
    end

    def date_is_present_and_correct
      date_is_present_and_plausible
      return if errors.any?

      date_is_in_future
    end

    def date_is_present_and_plausible
      unless date_present?("start_outline_business_case") &&
             date_plausible?("start_outline_business_case")
        errors.add(
          :award_contract,
          "Enter the date you expect to award the project's main contract"
        )
      end
    end

    def date_is_in_future
      return unless date_present?("start_outline_business_case") && !date_in_future?("start_outline_business_case")

      errors.add(
        :start_outline_business_case,
        "You cannot enter a date in the past"
      )
    end
  end
end
