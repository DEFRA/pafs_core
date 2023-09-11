# frozen_string_literal: true

require "csv"

module PafsCore
  module DataMigration
    class RemovePreviousYears
      attr_reader :project, :current_year

      def self.perform_all
        PafsCore::Project.find_each do |project|
          new(project).perform
        end
      end

      def initialize(project)
        @project = project
      end

      def perform
        @current_year = Time.zone.today.uk_financial_year

        ActiveRecord::Base.transaction do
          prune_years(:funding_values)
          prune_years(:flood_protection_outcomes)
          prune_years(:flood_protection2040_outcomes)
          prune_years(:coastal_erosion_protection_outcomes)
        end
      end

      def prune_years(annual_attribute)
        @project.send(annual_attribute).where("financial_year < ?", current_year).destroy_all
      end
    end
  end
end
