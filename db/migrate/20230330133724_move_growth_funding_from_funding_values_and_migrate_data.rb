# frozen_string_literal: true

class MoveGrowthFundingFromFundingValuesAndMigrateData < ActiveRecord::Migration[6.1]
  def up
    PafsCore::DataMigration::MoveGrowthFundingToOtherAdditionalGia.up
    remove_column :pafs_core_funding_values, :growth_funding
  end

  def down
    add_column :pafs_core_funding_values, :growth_funding, :integer
    PafsCore::DataMigration::MoveGrowthFundingToOtherAdditionalGia.down
  end
end
