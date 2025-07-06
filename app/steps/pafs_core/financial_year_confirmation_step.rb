# frozen_string_literal: true

module PafsCore
  class FinancialYearConfirmationStep < PafsCore::BasicStep
    def update
      new_latest_date = PafsCore::FinancialYearUtilities.financial_year_end_date(project.pending_financial_year)

      DateRangeDataCleaner.new(project, latest_date: new_latest_date).clean_data_outside_range!

      project.update!(
        project_end_financial_year: project.pending_financial_year,
        pending_financial_year: nil,
        date_change_requires_confirmation: false
      )
    end
  end
end
