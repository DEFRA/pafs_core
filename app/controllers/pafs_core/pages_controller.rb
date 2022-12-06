# frozen_string_literal: true

module PafsCore
  class PagesController < PafsCore::ApplicationController
    helper_method :previous_page

    protected

    def previous_page
      request.referer.presence ? request.referer : "/"
    end
  end
end
