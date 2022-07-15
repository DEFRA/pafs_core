class AddNoPropertiesAffectedByFlooding2040ToPafsCoreProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :pafs_core_projects, :no_properties_affected_by_flooding_2040, :boolean, default: false, null: false
  end
end
