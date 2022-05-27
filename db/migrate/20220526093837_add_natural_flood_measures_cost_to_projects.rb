class AddNaturalFloodMeasuresCostToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :pafs_core_projects, :natural_flood_measures_cost, :float
  end
end
