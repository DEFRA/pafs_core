# frozen_string_literal: true

class AddCarbonValuesHashStringToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :pafs_core_projects, :carbon_values_hexdigest, :string
  end
end
