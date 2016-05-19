# This migration comes from pafs_core (originally 20160427111306)
class AddLocationAndBenefitAreaToProject < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :project_location, :text, array: true, default: []
    add_column :pafs_core_projects, :project_location_zoom_level, :integer, default: 6
    add_column :pafs_core_projects, :benefit_area, :text, default: "[]"
    add_column :pafs_core_projects, :benefit_area_centre, :text, array: true, default: []
    add_column :pafs_core_projects, :benefit_area_zoom_level, :integer, default: 6
  end
end
