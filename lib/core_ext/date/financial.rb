# frozen_string_literal: true

module CoreExtensions
  module Date
    module Financial
      def uk_financial_year
        if month < 4
          year - 1
        else
          year
        end
      end
    end
  end
end
