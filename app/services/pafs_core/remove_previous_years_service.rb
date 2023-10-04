# frozen_string_literal: true

module PafsCore
  class RemovePreviousYearsService
    attr_reader :project, :current_year

    def initialize(project)
      @project = project
      @current_year = Time.zone.today.uk_financial_year
    end

    def run
      return if project.state.state == "submitted"

      ActiveRecord::Base.transaction do
        prune_years(:funding_values)
        prune_years(:flood_protection_outcomes)
        prune_years(:flood_protection2040_outcomes)
        prune_years(:coastal_erosion_protection_outcomes)
      end
    end

    private

    def prune_years(annual_attribute)
      project.send(annual_attribute).where("financial_year < ?", current_year).destroy_all
    end
  end
end
