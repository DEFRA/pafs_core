# frozen_string_literal: true

module PafsCore
  module Carbon
    delegate :carbon_cost_build, :carbon_cost_build=,
             :carbon_cost_operation, :carbon_cost_operation=,
             :carbon_cost_sequestered, :carbon_cost_sequestered=,
             :carbon_cost_avoided, :carbon_cost_avoided=,
             :carbon_savings_net_economic_benefit, :carbon_savings_net_economic_benefit=,
             :carbon_operational_cost_forecast, :carbon_operational_cost_forecast=,
             to: :project

    def carbon_required_information_present?
      required = %i[
        start_construction_month start_construction_year
        ready_for_service_month ready_for_service_year
      ]

      # check required fields
      return false unless required.all? { |field_name| project.send(field_name).present? }

      # check funding sources
      return false unless PafsCore::ValidationPresenter.new(project).funding_sources_complete?

      true
    end
  end
end
