class AddHouseholdsProtectedThroughPlpMeasuresToPafsCoreFloodProtectionOutcomes < ActiveRecord::Migration[6.0]
  def change
    add_column :pafs_core_flood_protection_outcomes, :households_protected_through_plp_measures, :integer
    add_column :pafs_core_flood_protection_outcomes, :non_residential_properties, :integer
  end
end
