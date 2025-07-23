# frozen_string_literal: true

class RemoveNotNullConstraintFromDateChangeRequiresConfirmation < ActiveRecord::Migration[7.2]
  def change
    change_column_null :pafs_core_projects, :date_change_requires_confirmation, true
    change_column_default :pafs_core_projects, :date_change_requires_confirmation, from: false, to: nil
  end
end
