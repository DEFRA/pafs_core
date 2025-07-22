# frozen_string_literal: true

module PafsCore
  class EarliestStartDateStep < BasicStep
    include PafsCore::DateUtils
    delegate :earliest_start_month, :earliest_start_month=,
             :earliest_start_year, :earliest_start_year=,
             :project_end_financial_year,
             :pending_earliest_start_month, :pending_earliest_start_month=,
             :pending_earliest_start_year, :pending_earliest_start_year=,
             :date_change_requires_confirmation, :date_change_requires_confirmation=,
             to: :project

    validate :date_is_present_and_correct

    def before_view(_params)
      project.update(
        pending_earliest_start_month: nil,
        pending_earliest_start_year: nil,
        date_change_requires_confirmation: nil
      )
    end

    def update(params)
      original_month = project.earliest_start_month
      original_year = project.earliest_start_year
      assign_attributes(step_params(params))

      return false unless valid?

      if project.is_a?(PafsCore::Project)
        checker = PafsCore::DateRangeDataChecker.new(
          project,
          earliest_date: Date.new(earliest_start_year, earliest_start_month, 1)
        )

        if checker.data_outside_date_range?
          project.pending_earliest_start_month = earliest_start_month
          project.pending_earliest_start_year = earliest_start_year
          project.date_change_requires_confirmation = true
          # Revert the dates to original until it's confirmed user wants to proceed
          project.earliest_start_month = original_month
          project.earliest_start_year = original_year
        end
      end

      project.updated_by = user if project.respond_to?(:updated_by)
      project.save
    end

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
