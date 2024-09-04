# frozen_string_literal: true

class AddUniqueIndexToProjectsName < ActiveRecord::Migration[7.2]
  def change
    add_index :pafs_core_projects, :name, unique: true
  end
end
