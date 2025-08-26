# frozen_string_literal: true

class AddCarbonOperationalCostToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :pafs_core_projects, :carbon_operational_cost, :decimal, precision: 20, scale: 2
  end
end
