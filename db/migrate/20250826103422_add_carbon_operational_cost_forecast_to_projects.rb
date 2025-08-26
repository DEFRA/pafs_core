# frozen_string_literal: true

class AddCarbonOperationalCostForecastToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :pafs_core_projects, :carbon_operational_cost_forecast, :integer, limit: 8
  end
end
