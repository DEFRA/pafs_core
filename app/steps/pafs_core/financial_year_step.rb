# frozen_string_literal: true

module PafsCore
  class FinancialYearStep < BasicStep
    include PafsCore::FinancialYear
    include PafsCore::ProjectsHelper
    delegate :project_end_financial_year, :project_end_financial_year=,
             :earliest_start_month, :earliest_start_year,
             :pending_financial_year, :pending_financial_year=,
             :date_change_requires_confirmation, :date_change_requires_confirmation=,
             to: :project

    validate :project_end_financial_year_is_present_and_correct

    def before_view(_params)
      project.update(
        pending_financial_year: nil,
        date_change_requires_confirmation: nil
      )
    end

    def update(params)
      @javascript_enabled = params.fetch(:js_enabled, false)
      original_year = project.project_end_financial_year
      assign_attributes(step_params(params))

      return false unless valid?

      checker = PafsCore::DateRangeDataChecker.new(
        project,
        latest_date: financial_year_end_from_year(project_end_financial_year)
      )

      if checker.data_outside_date_range?
        project.pending_financial_year = project_end_financial_year
        project.date_change_requires_confirmation = true
        # Revert the date to original until it's confirmed user wants to proceed
        # even with data loss
        project.project_end_financial_year = original_year
      end

      project.updated_by = user if project.respond_to?(:updated_by)
      project.save
    end

    private

    def step_params(params)
      params
        .require(:financial_year_step)
        .permit(:project_end_financial_year)
    end
  end
end
