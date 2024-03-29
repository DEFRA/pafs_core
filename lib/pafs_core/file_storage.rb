# frozen_string_literal: true

module PafsCore
  module FileStorage
    def storage
      @storage ||= if Rails.env.local?
                     PafsCore::DevelopmentFileStorageService.new
                   else
                     PafsCore::FileStorageService.new
                   end
    end
  end
end
