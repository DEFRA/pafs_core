# frozen_string_literal: true

module PafsCore
  class EarliestStartDateConfirmationStep < PafsCore::BasicStep
    def update
      new_start_date = Date.new(project.pending_earliest_start_year, project.pending_earliest_start_month, 1)

      DateRangeDataCleaner.new(project, earliest_date: new_start_date).clean_data_outside_range!

      project.update!(
        earliest_start_year: project.pending_earliest_start_year,
        earliest_start_month: project.pending_earliest_start_month,
        pending_earliest_start_year: nil,
        pending_earliest_start_month: nil,
        date_change_requires_confirmation: false
      )
    end
  end
end
