# frozen_string_literal: true

class UpdateAuthorityData < ActiveRecord::Migration[7.0]
  def up
    PafsCore::DataMigration::UpdateAuthorities.up
  end

  def down
    PafsCore::DataMigration::UpdateAuthorities.down
  end
end
