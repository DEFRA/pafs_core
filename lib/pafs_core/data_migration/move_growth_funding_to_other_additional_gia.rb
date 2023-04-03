# frozen_string_literal: true

module PafsCore
  module DataMigration
    class MoveGrowthFundingToOtherAdditionalGia
      class << self
        def up
          funding_values = PafsCore::FundingValue.where.not(growth_funding: nil, growth_funding: 0)
          funding_values.each do |fv|
            fv.update(other_additional_grant_in_aid: fv.growth_funding, growth_funding: nil)
            raise ActiveRecord::Rollback unless fv.other_additional_grant_in_aid?
          end
        end

        def down
          funding_values = PafsCore::FundingValue.where.not(other_additional_grant_in_aid: nil,
                                                            other_additional_grant_in_aid: 0)
          funding_values.each do |fv|
            fv.update(growth_funding: fv.other_additional_grant_in_aid, other_additional_grant_in_aid: nil)
          end
        end
      end
    end
  end
end
