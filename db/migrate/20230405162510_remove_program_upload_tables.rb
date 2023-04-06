class RemoveProgramUploadTables < ActiveRecord::Migration[6.1]
  def change
    remove_table :pafs_core_program_uploads
    remove_table :pafs_core_program_upload_items
    remove_table :pafs_core_program_upload_failures
  end
end
