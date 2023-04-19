class ChangeAndAddEarliestStartColumns < ActiveRecord::Migration[6.1]
  def up
    rename_column :pafs_core_projects, :earliest_start_month, :earliest_with_gia_month
    rename_column :pafs_core_projects, :earliest_start_year, :earliest_with_gia_year

    add_column :pafs_core_projects, :earliest_start_month, :integer
    add_column :pafs_core_projects, :earliest_start_year, :integer
  end

  def down
    remove_column :pafs_core_projects, :earliest_start_month
    remove_column :pafs_core_projects, :earliest_start_year

    rename_column :pafs_core_projects, :earliest_with_gia_month, :earliest_start_month
    rename_column :pafs_core_projects, :earliest_with_gia_year, :earliest_start_year
  end
end
