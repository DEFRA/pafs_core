# frozen_string_literal: true

class AddMoreCarbonFieldsToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :pafs_core_projects, :carbon_cost_sequestered, :decimal, precision: 20, scale: 2
    add_column :pafs_core_projects, :carbon_cost_avoided, :decimal, precision: 20, scale: 2
    add_column :pafs_core_projects, :carbon_savings_net_economic_benefit, :decimal, precision: 20, scale: 2
  end
end
