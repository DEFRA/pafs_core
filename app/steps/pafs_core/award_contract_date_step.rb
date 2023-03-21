# frozen_string_literal: true

module PafsCore
  class AwardContractDateStep < BasicStep
    delegate :award_contract_month, :award_contract_month=,
             :award_contract_year, :award_contract_year=,
             :start_outline_business_case_month, :start_outline_business_case_year,
             :date_present?, :date_in_range?, :date_later_than?,
             to: :project

    validate :date_is_present_and_in_range
    validate :date_is_later_than_compjlete_outline_business_case

    private

    def step_params(params)
      params
        .require(:award_contract_date_step)
        .permit(:award_contract_month, :award_contract_year)
    end

    def date_is_present_and_in_range
      return if date_present?("award_contract") && date_in_range?("award_contract")

      errors.add(
        :award_contract,
        "Enter the date you expect to award the project's main contract"
      )
    end

    def date_is_present_and_correct
      date_is_present_and_in_range
      return if errors.any?

      award_contract_after_start_outline_business_case
    end

    def date_is_later_than_compjlete_outline_business_case
      if date_present?("award_contract") &&
         date_present?("complete_outline_business_case") &&
         date_later_than?("complete_outline_business_case", "award_contract")
        errors.add(
          :award_contract,
          "You expect to complete your outline business case on #{project.complete_outline_business_case_month} " \
          "#{project.complete_outline_business_case_year}. " \
          "The date you expect to award the project’s main contract must come after this date."
        )
      end
    end
  end
end
