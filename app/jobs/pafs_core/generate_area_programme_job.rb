# frozen_string_literal: true

module PafsCore
  class GenerateAreaProgrammeJob < ApplicationJob
    include PafsCore::FileStorage
    include PafsCore::Files

    def perform(user_id)
      ApplicationRecord.connection_pool.with_connection do
        user = PafsCore::User.find(user_id)
        PafsCore::Download::Area.perform(user)
        # PafsCore::AreaDownloadService.new(PafsCore::User.find(user_id)).generate_area_programme
      end
    end
  end
end
