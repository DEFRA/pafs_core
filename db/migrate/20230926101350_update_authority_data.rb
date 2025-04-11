# frozen_string_literal: true

class UpdateAuthorityData < ActiveRecord::Migration[7.0]
  delegate :up, to: :"PafsCore::DataMigration::UpdateAuthorities"

  delegate :down, to: :"PafsCore::DataMigration::UpdateAuthorities"
end
