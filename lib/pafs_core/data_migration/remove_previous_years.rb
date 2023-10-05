# frozen_string_literal: true

module PafsCore
  module DataMigration
    class RemovePreviousYears

      def self.perform(max_projects = 100)
        processed_project_count = 0

        # The funding_values cleanup for a given project will also clear out any previous
        # years data for the other annualised attributes. We run the service for each of
        # those attributes to handle any cases where previous years funding_values were not
        # present but previous years data was present for another attribute.
        %i[funding_values
           flood_protection_outcomes
           flood_protection2040_outcomes
           coastal_erosion_protection_outcomes].each do |attribute|
          projects = qualifying_projects(attribute, max_projects - processed_project_count)
          puts "Processing #{projects.length}/#{max_projects} projects based on #{attribute}" unless Rails.env.test?
          projects.each do |project|
            PafsCore::RemovePreviousYearsService.new(project).run
          end

          processed_project_count += projects.length
          break if processed_project_count >= max_projects
        end
      end

      def self.qualifying_projects(attribute, project_limit)
        PafsCore::Project
          .joins(:state)
          .where.not(pafs_core_states: { state: :submitted })
          .joins(attribute)
          .distinct
          .where("pafs_core_#{attribute}.financial_year < ?", current_year)
          .limit(project_limit)
      end

      def self.current_year
        @current_year = Time.zone.today.uk_financial_year
      end
    end
  end
end
