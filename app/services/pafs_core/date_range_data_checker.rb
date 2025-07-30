# frozen_string_literal: true

module PafsCore
  # Checks for project data (funding or outcomes) that falls outside a given
  # date range. This is used to warn the user before they change a project's
  # dates and inadvertently delete data.
  class DateRangeDataChecker
    include PafsCore::ProjectsHelper
    attr_reader :project, :earliest_date, :latest_date

    def initialize(project, earliest_date: nil, latest_date: nil)
      @project = project
      @earliest_date = earliest_date || default_earliest_date
      @latest_date = latest_date || default_latest_date
    end

    def data_outside_date_range?
      relations_for_records_outside_range.any?(&:exists?)
    end

    def relations_for_records_outside_range
      @relations_for_records_outside_range ||= [
        project.funding_values.where("total > 0").where(years_out_of_range_scope),
        project.flood_protection_outcomes.with_positive_values.where(years_out_of_range_scope),
        project.flood_protection2040_outcomes.with_positive_values.where(years_out_of_range_scope),
        project.coastal_erosion_protection_outcomes.with_positive_values.where(years_out_of_range_scope)
      ]
    end

    private

    def years_out_of_range_scope
      ["financial_year < ? OR financial_year > ?", earliest_date.year, latest_date.year]
    end

    def default_earliest_date
      if project.earliest_start_year.present? && project.earliest_start_month.present?
        return Date.new(project.earliest_start_year, project.earliest_start_month, 1)
      end

      Time.zone.today
    end

    def default_latest_date
      if project.project_end_financial_year.present?
        financial_year_start = Date.new(project.project_end_financial_year, 4, 1)
        return financial_year_end_for(financial_year_start)
      end

      10.years.from_now
    end
  end
end
