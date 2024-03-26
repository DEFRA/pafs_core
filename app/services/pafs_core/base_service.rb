# frozen_string_literal: true

module PafsCore
  class BaseService
    def self.run(options = nil)
      if options && !options.is_a?(Hash)
        new.run(options)
      elsif options
        new.run(**options)
      else
        new.run
      end
    end
  end
end
