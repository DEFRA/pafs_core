class AddNaturalFloodMeasuresToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :pafs_core_projects, :natural_flood_risk_measures_included, :boolean
    add_column :pafs_core_projects, :river_restoration, :boolean
    add_column :pafs_core_projects, :floodplain_restoration, :boolean
    add_column :pafs_core_projects, :leaky_barriers, :boolean
    add_column :pafs_core_projects, :offline_flood_storage_areas, :boolean
    add_column :pafs_core_projects, :cross_slope_woodland, :boolean
    add_column :pafs_core_projects, :catchment_woodland, :boolean
    add_column :pafs_core_projects, :riparian_woodland, :boolean
    add_column :pafs_core_projects, :floodplain_woodland, :boolean
    add_column :pafs_core_projects, :soil_and_land_management, :boolean
    add_column :pafs_core_projects, :land_and_headwater_drainage_management, :boolean
    add_column :pafs_core_projects, :runoff_pathway_management, :boolean
    add_column :pafs_core_projects, :saltmarsh_mudflats_and_managed_realignment, :boolean
    add_column :pafs_core_projects, :sand_dunes, :boolean
    add_column :pafs_core_projects, :beach_nourishment, :boolean
    add_column :pafs_core_projects, :other_flood_measures, :string
    add_column :pafs_core_projects, :natural_flood_risk_measures_cost, :float
  end
end
