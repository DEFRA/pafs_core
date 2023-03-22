# frozen_string_literal: true

module PafsCore
  class StartConstructionDateStep < BasicStep
    delegate :start_construction_month, :start_construction_month=,
             :start_construction_year, :start_construction_year=,
             :award_contract_month, :award_contract_year,
             :date_present?, :date_plausible?, :date_later_than?,
             to: :project

    validate :date_is_present_and_correct

    private

    def step_params(params)
      params
        .require(:start_construction_date_step)
        .permit(:start_construction_month, :start_construction_year)
    end

    def date_is_present_and_correct
      date_is_present_and_plausible
      return if errors.any?

      date_is_later_than_award_contract
    end

    def date_is_present_and_plausible
      unless date_present?("start_construction") &&
             date_plausible?("start_construction")
        errors.add(
          :award_contract,
          "Enter the date you expect to award the project's main contract"
        )
      end
    end

    def date_is_later_than_award_contract
      if date_present?("award_contract") &&
         date_present?("start_construction") &&
         date_later_than?("award_contract", "start_construction")
        errors.add(
          :start_construction,
          "You expect to award the project's main contract on #{project.award_contract_month} " \
          "#{project.award_contract_year}. " \
          "The date you expect to start the work must come after this date."
        )
      end
    end
  end
end
