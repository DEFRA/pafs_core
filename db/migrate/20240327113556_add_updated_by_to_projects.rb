# frozen_string_literal: true

class AddUpdatedByToProjects < ActiveRecord::Migration[7.1]
  def change
    add_reference :pafs_core_projects, :updated_by, polymorphic: true, null: true
  end
end
