# frozen_string_literal: true

module PafsCore
  module Spreadsheet
    module Contributors
      module Coerce
        class Base
          attr_reader :value

          def self.perform(val)
            new(val).perform
          end

          def initialize(val)
            @value = val.to_s.strip
          end

          def perform
            raise("override #perform")
          end
        end
      end
    end
  end
end
