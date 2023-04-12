# frozen_string_literal: true

class RemoveProgramUploadTables < ActiveRecord::Migration[6.1]
  def change
    drop_table :pafs_core_program_uploads
    drop_table :pafs_core_program_upload_items
    drop_table :pafs_core_program_upload_failures
  end
end
