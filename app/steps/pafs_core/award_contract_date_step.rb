# frozen_string_literal: true

module PafsCore
  class AwardContractDateStep < BasicStep
    delegate :award_contract_month, :award_contract_month=,
             :award_contract_year, :award_contract_year=,
             :start_outline_business_case_month, :start_outline_business_case_year,
             :date_present?, :date_plausible?, :date_later_than?,
             to: :project

    validate :date_is_present_and_correct

    private

    def step_params(params)
      params
        .require(:award_contract_date_step)
        .permit(:award_contract_month, :award_contract_year)
    end

    def date_is_present_and_correct
      date_is_present_and_plausible
      return if errors.any?

      date_is_later_than_complete_outline_business_case
    end

    def date_is_present_and_plausible
      unless date_present?("award_contract") &&
             date_plausible?("award_contract")
        errors.add(
          :award_contract,
          "Enter the date you expect to award the project's main contract"
        )
      end
    end

    def date_is_later_than_complete_outline_business_case
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
