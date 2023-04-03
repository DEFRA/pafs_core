# frozen_string_literal: true

module PafsCore
  module DataMigration
    class MoveGrowthFundingToOtherAdditionalGia
      class << self
        def up
          funding_values = PafsCore::FundingValue.where("growth_funding IS NOT NULL AND growth_funding != 0")
          funding_values.each do |fv|
            fv.update(other_additional_grant_in_aid: fv.growth_funding, growth_funding: nil)
            raise ActiveRecord::Rollback unless fv.other_additional_grant_in_aid?
          end
        end

        def down
          funding_values = PafsCore::FundingValue
                           .where("other_additional_grant_in_aid IS NOT NULL AND other_additional_grant_in_aid != 0")
          funding_values.each do |fv|
            fv.update(growth_funding: fv.other_additional_grant_in_aid, other_additional_grant_in_aid: nil)
          end
        end
      end
    end
  end
end
