# frozen_string_literal: true

module PafsCore
  class PsoRfccService
    class << self
      def map
        PafsCore::Area.pso_areas.select(:name, :sub_type).to_h { |a| [a.name, a.sub_type] }
      end
    end
  end
end
