# frozen_string_literal: true

class AddOtherFloodMeasureSelected < ActiveRecord::Migration[6.0]
  def change
    add_column :pafs_core_projects, :other_flood_measures_selected, :boolean
  end
end
