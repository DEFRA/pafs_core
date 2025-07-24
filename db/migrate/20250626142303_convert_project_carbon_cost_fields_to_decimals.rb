# frozen_string_literal: true

class ConvertProjectCarbonCostFieldsToDecimals < ActiveRecord::Migration[7.2]
  def up
    change_table :pafs_core_projects do |t|
      t.change :carbon_cost_build, :decimal, precision: 20, scale: 2
      t.change :carbon_cost_operation, :decimal, precision: 20, scale: 2
    end
  end

  def down
    change_table :pafs_core_projects do |t|
      t.change :carbon_cost_build, :integer, limit: 8
      t.change :carbon_cost_operation, :integer, limit: 8
    end
  end
end
