# frozen_string_literal: true

class AddUniqueIndexToProjectsName < ActiveRecord::Migration[7.1]
  def up
    # Remove the index if it exists
    remove_index :pafs_core_projects, name: "index_pafs_core_projects_on_name", if_exists: true

    # Make names unique
    duplicates = PafsCore::Project.select(:name).group(:name).having("count(*) > 1").pluck(:name)

    duplicates.each do |name|
      PafsCore::Project.where(name: name).each_with_index do |project, index|
        next if index.zero? # skip the first one

        new_name = "#{name} (#{index + 1})"
        # rubocop:disable Rails/SkipsModelValidations
        project.update_column(:name, new_name)
        # rubocop:enable Rails/SkipsModelValidations
      end
    end

    # Add the unique index
    add_index :pafs_core_projects, :name, unique: true, name: "index_pafs_core_projects_on_name"
  end

  def down
    remove_index :pafs_core_projects, name: "index_pafs_core_projects_on_name"
  end
end
