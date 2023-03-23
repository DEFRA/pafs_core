class AddCompleteOutlineBusinessCaseDatesToPafsCoreProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :pafs_core_projects, :complete_outline_business_case_month, :integer
    add_column :pafs_core_projects, :complete_outline_business_case_year, :integer
  end
end
