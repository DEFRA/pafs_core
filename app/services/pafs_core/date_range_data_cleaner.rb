# frozen_string_literal: true

module PafsCore
  # Deletes project data (funding or outcomes) that falls outside a given
  # date range. This is used when a user confirms a change to a project's dates.
  class DateRangeDataCleaner
    attr_reader :project, :earliest_date, :latest_date

    def initialize(project, earliest_date: nil, latest_date: nil)
      @project = project
      @earliest_date = earliest_date
      @latest_date = latest_date
    end

    def clean_data_outside_range!
      # Ensure we only clean data for Draft projects
      raise StandardError, "DateRangeDataCleaner should only be used on projects in Draft state" unless project.draft?

      begin
        checker = DateRangeDataChecker.new(
          project,
          earliest_date: earliest_date,
          latest_date: latest_date
        )

        ActiveRecord::Base.transaction do
          checker.relations_for_records_outside_range.each(&:delete_all)
        end

        true
      rescue StandardError => e
        Rails.logger.error("Error cleaning data outside date range: #{e.message}")
        false
      end
    end
  end
end
