# frozen_string_literal: true

class ChangeCarbonSavingsNetEconomicBenefitToInteger < ActiveRecord::Migration[7.2]
  def up
    change_column :pafs_core_projects, :carbon_savings_net_economic_benefit, :integer, limit: 8
  end

  def down
    change_column :pafs_core_projects, :carbon_savings_net_economic_benefit, :decimal, precision: 20, scale: 2
  end
end
