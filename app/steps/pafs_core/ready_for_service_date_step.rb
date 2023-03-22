# frozen_string_literal: true

module PafsCore
  class ReadyForServiceDateStep < BasicStep
    delegate :ready_for_service_month, :ready_for_service_month=,
             :ready_for_service_year, :ready_for_service_year=,
             :start_construction_month, :start_construction_year,
             :date_present?, :date_in_range?, :date_later_than?,
             to: :project

    validate :date_is_present_and_correct

    private

    def step_params(params)
      params.require(:ready_for_service_date_step).permit(
        :ready_for_service_month, :ready_for_service_year
      )
    end

    def date_is_present_and_correct
      date_is_present_and_in_range
      return if errors.any?

      date_is_later_than_start_construction
    end

    def date_is_present_and_in_range
      unless date_present?("ready_for_service") &&
             date_in_range?("ready_for_service")
        errors.add(
          :ready_for_service,
          "Enter the date you expect the project to start achieving its benefits"
        )
      end
    end

    def date_is_later_than_start_construction
      if date_present?("start_construction") &&
          date_present?("ready_for_service") &&
          date_later_than?("start_construction", "ready_for_service")
        errors.add(
          :ready_for_service,
          "You expect to start the work on #{project.start_construction_month} " \
          "#{project.start_construction_year}. " \
          "The date you expect the project to start achieving its benefits must come after this date."
        )
      end
    end
  end
end
