class AddOm4AttributesToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :pafs_core_projects, :environmental_benefits, :boolean
    add_column :pafs_core_projects, :intertidal_habitat, :boolean
    add_column :pafs_core_projects, :hectares_of_intertidal_habitat_created_or_enhanced, :float
    add_column :pafs_core_projects, :woodland, :boolean
    add_column :pafs_core_projects, :hectares_of_woodland_habitat_created_or_enhanced, :float
    add_column :pafs_core_projects, :wet_woodland, :boolean
    add_column :pafs_core_projects, :hectares_of_wet_woodland_habitat_created_or_enhanced, :float
    add_column :pafs_core_projects, :wetland_or_wet_grassland, :boolean
    add_column :pafs_core_projects, :hectares_of_wetland_or_wet_grassland_created_or_enhanced, :float
    add_column :pafs_core_projects, :grassland, :boolean
    add_column :pafs_core_projects, :hectares_of_grassland_habitat_created_or_enhanced, :float
    add_column :pafs_core_projects, :heathland, :boolean
    add_column :pafs_core_projects, :hectares_of_heathland_created_or_enhanced, :float
    add_column :pafs_core_projects, :ponds_lakes, :boolean
    add_column :pafs_core_projects, :hectares_of_pond_or_lake_habitat_created_or_enhanced, :float
    add_column :pafs_core_projects, :arable_land, :boolean
    add_column :pafs_core_projects, :hectares_of_arable_land_lake_habitat_created_or_enhanced, :float
    add_column :pafs_core_projects, :comprehensive_restoration, :boolean
    add_column :pafs_core_projects, :kilometres_of_watercourse_enhanced_or_created_comprehensive, :float
    add_column :pafs_core_projects, :partial_restoration, :boolean
    add_column :pafs_core_projects, :kilometres_of_watercourse_enhanced_or_created_partial, :float
    add_column :pafs_core_projects, :create_habitat_watercourse, :boolean
    add_column :pafs_core_projects, :kilometres_of_watercourse_enhanced_or_created_single, :float
  end
end
