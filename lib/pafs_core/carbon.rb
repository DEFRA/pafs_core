# frozen_string_literal: true

module PafsCore
  module Carbon
    delegate :carbon_cost_build, :carbon_cost_build=,
             :carbon_cost_operation, :carbon_cost_operation=,
             :carbon_cost_sequestered, :carbon_cost_sequestered=,
             :carbon_cost_avoided, :carbon_cost_avoided=,
             :carbon_savings_net_economic_benefit, :carbon_savings_net_economic_benefit=,
             to: :project
  end
end
