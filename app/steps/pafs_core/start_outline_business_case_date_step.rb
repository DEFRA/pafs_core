# frozen_string_literal: true

module PafsCore
  class StartOutlineBusinessCaseDateStep < BasicStep
    delegate :start_outline_business_case_month, :start_outline_business_case_month=,
             :start_outline_business_case_year, :start_outline_business_case_year=,
             to: :project

    validate :date_is_present_and_plausible

    private

    def step_params(params)
      params
        .require(:start_outline_business_case_date_step)
        .permit(:start_outline_business_case_month, :start_outline_business_case_year)
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
  end
end
