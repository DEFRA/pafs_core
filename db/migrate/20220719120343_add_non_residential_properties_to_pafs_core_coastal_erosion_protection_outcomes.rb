class AddNonResidentialPropertiesToPafsCoreCoastalErosionProtectionOutcomes < ActiveRecord::Migration[6.0]
  def change
    add_column :pafs_core_coastal_erosion_protection_outcomes, :non_residential_properties, :integer
  end
end
