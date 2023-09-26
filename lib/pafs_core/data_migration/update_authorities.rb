# frozen_string_literal: true

module PafsCore
  module DataMigration
    class UpdateAuthorities
      class << self
        def up
          authorities = {
            "DBC" => "District",
            "EA" => "Environment Agency",
            "HA" => "Highway Authority",
            "IDB" => "Internal Drainage Board",
            "LA" => "Local Authority",
            "LLFA" => "Lead Local Flood Authority",
            "WC" => "Water Company"
          }

          authorities.each do |identifier, name|
            authority = PafsCore::Area.find_by(area_type: PafsCore::Area::AUTHORITY, identifier: identifier)
            next if authority.present?

            PafsCore::Area.create(
              name: name,
              area_type: PafsCore::Area::AUTHORITY,
              identifier: identifier
            )
          end
        end

        def down
          PafsCore::Area.where(area_type: PafsCore::Area::AUTHORITY).destroy_all
        end
      end
    end
  end
end
