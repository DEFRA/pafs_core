# frozen_string_literal: true

class AddIdentifierAndEndDateToAreas < ActiveRecord::Migration[7.0]
  def change
    add_column :pafs_core_areas, :identifier, :string
    add_column :pafs_core_areas, :end_date, :date
  end
end
