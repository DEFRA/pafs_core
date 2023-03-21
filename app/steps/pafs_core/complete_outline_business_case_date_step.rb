# frozen_string_literal: true

module PafsCore
  class CompleteOutlineBusinessCaseDateStep < BasicStep
    delegate :complete_outline_business_case_month, :complete_outline_business_case_month=,
             :complete_outline_business_case_year, :complete_outline_business_case_year=,
             :date_present?, :date_in_range?, :date_later_than?,
             to: :project

    validate :date_is_present_and_in_range
    validate :date_is_later_than_start_outline_business_case

    private

    def step_params(params)
      params
        .require(:complete_outline_business_case_date_step)
        .permit(:complete_outline_business_case_month, :complete_outline_business_case_year)
    end

    def date_is_present_and_in_range
      unless date_present?("complete_outline_business_case") &&
             date_in_range?("complete_outline_business_case")
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
          "The date you expect your outline business case must come after this date."
        )
      end
    end
  end
end
