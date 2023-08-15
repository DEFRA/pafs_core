# frozen_string_literal: true

class CreatePafsCoreOrganisations < ActiveRecord::Migration[7.0]
  def change
    create_table :pafs_core_organisations do |t|
      t.string :name, null: false, index: true
      t.string :organisation_type, null: false, index: true

      t.timestamps
    end
  end
end
