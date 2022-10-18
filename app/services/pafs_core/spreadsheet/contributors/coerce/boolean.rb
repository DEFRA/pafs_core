# frozen_string_literal: true

module PafsCore
  module Spreadsheet
    module Contributors
      module Coerce
        class Boolean < Base
          def perform
            value == "yes"
          end
        end
      end
    end
  end
end
