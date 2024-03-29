# frozen_string_literal: true

module PafsCore
  class CompleteOutlineBusinessCaseDateStep < BasicStep
    delegate :complete_outline_business_case_month, :complete_outline_business_case_month=,
             :complete_outline_business_case_year, :complete_outline_business_case_year=,
             :date_present?, :date_plausible?, :date_later_than?,
             to: :project

    validate :date_is_present_and_correct

    private

    def step_params(params)
      params
        .require(:complete_outline_business_case_date_step)
        .permit(:complete_outline_business_case_month, :complete_outline_business_case_year)
    end

    def date_is_present_and_correct
      date_is_present_and_plausible
      return if errors.any?

      date_is_later_than_start_outline_business_case
    end

    def date_is_present_and_plausible
      unless date_present?("complete_outline_business_case") &&
             date_plausible?("complete_outline_business_case")
        errors.add(
          :complete_outline_business_case,
          "Enter the date you expect to complete the project’s outline business case"
        )
      end
    end

    def date_is_later_than_start_outline_business_case
      if date_present?("complete_outline_business_case") &&
         date_present?("start_outline_business_case") &&
         date_later_than?("start_outline_business_case", "complete_outline_business_case")
        errors.add(
          :award_contract,
          "You expect to start your outline business case on #{project.start_outline_business_case_month} " \
          "#{project.start_outline_business_case_year}. " \
          "The date you expect to complete your outline business case must come after this date."
        )
      end
    end
  end
end
