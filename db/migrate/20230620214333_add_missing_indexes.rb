# frozen_string_literal: true

class AddMissingIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :pafs_core_funding_values, :project_id
    add_index :pafs_core_funding_values, :financial_year
    add_index :pafs_core_funding_values, %i[project_id financial_year],
              name: :funding_values_on_project_id_and_financial_year

    add_index :pafs_core_coastal_erosion_protection_outcomes, :project_id, name: :cep_outcomes_on_project_id
    add_index :pafs_core_coastal_erosion_protection_outcomes, :financial_year, name: :cep_outcomes_on_financial_year
    add_index :pafs_core_coastal_erosion_protection_outcomes, %i[project_id financial_year],
              name: :cep_outcomes_on_project_id_and_financial_year

    add_index :pafs_core_flood_protection_outcomes, :project_id, name: :fp_outcomes_on_project_id
    add_index :pafs_core_flood_protection_outcomes, :financial_year, name: :fp_outcomes_on_financial_year
    add_index :pafs_core_flood_protection_outcomes, %i[project_id financial_year],
              name: :fp_outcomes_on_project_id_and_financial_year
  end
end
