class CreatePafsCoreFloodProtection2040Outcomes < ActiveRecord::Migration[6.0]
  def change
    create_table :pafs_core_flood_protection2040_outcomes do |t|
      t.integer :project_id
      t.integer :financial_year, null: false
      t.integer :households_at_reduced_risk
      t.integer :moved_from_very_significant_and_significant_to_moderate_or_low
      t.integer :households_protected_from_loss_in_20_percent_most_deprived
      t.integer :non_residential_properties
    end
  end
end
