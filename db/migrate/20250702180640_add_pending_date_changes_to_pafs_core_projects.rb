class AddPendingDateChangesToPafsCoreProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :pafs_core_projects, :pending_earliest_start_month, :integer
    add_column :pafs_core_projects, :pending_earliest_start_year, :integer
    add_column :pafs_core_projects, :pending_financial_year, :integer
    add_column :pafs_core_projects, :date_change_requires_confirmation, :boolean
  end
end
