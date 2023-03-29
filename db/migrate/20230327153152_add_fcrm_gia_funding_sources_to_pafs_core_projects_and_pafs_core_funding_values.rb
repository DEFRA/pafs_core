class AddFcrmGiaFundingSourcesToPafsCoreProjectsAndPafsCoreFundingValues < ActiveRecord::Migration[6.1]
  def change
    add_column :pafs_core_projects, :asset_replacement_allowance, :boolean, default: false
    add_column :pafs_core_projects, :environment_statutory_funding, :boolean, default: false
    add_column :pafs_core_projects, :frequently_flooded_communities, :boolean, default: false
    add_column :pafs_core_projects, :other_additional_grant_in_aid, :boolean, default: false
    add_column :pafs_core_projects, :other_government_department, :boolean, default: false
    add_column :pafs_core_projects, :recovery, :boolean, default: false
    add_column :pafs_core_projects, :summer_economic_fund, :boolean, default: false

    add_column :pafs_core_funding_values, :asset_replacement_allowance, :bigint
    add_column :pafs_core_funding_values, :environment_statutory_funding, :bigint
    add_column :pafs_core_funding_values, :frequently_flooded_communities, :bigint
    add_column :pafs_core_funding_values, :other_additional_grant_in_aid, :bigint
    add_column :pafs_core_funding_values, :other_government_department, :bigint
    add_column :pafs_core_funding_values, :recovery, :bigint
    add_column :pafs_core_funding_values, :summer_economic_fund, :bigint
  end
end
