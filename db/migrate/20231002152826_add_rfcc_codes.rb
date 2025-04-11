# frozen_string_literal: true

class AddRfccCodes < ActiveRecord::Migration[7.0]
  delegate :up, to: :"PafsCore::DataMigration::AddRfccCodes"

  delegate :down, to: :"PafsCore::DataMigration::AddRfccCodes"
end
