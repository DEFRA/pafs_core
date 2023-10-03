# frozen_string_literal: true

class AddRfccCodes < ActiveRecord::Migration[7.0]
  def up
    PafsCore::DataMigration::AddRfccCodes.up
  end

  def down
    PafsCore::DataMigration::AddRfccCodes.down
  end
end
