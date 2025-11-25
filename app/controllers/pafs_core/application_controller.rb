# frozen_string_literal: true

module PafsCore
  class ApplicationController < ActionController::Base # NOSONAR
    include PafsCore::ApplicationHelper
    include PafsCore::CustomHeaders

    protect_from_forgery with: :exception

    before_action :cache_busting

    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_authenticity_token

    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    private

    def raise_not_found
      raise ActionController::RoutingError, "Not Found"
    end

    def handle_invalid_authenticity_token(exception)
      Airbrake.notify(exception)
      Rails.logger.error "ApplicationController authenticity failed " \
                         "(browser cookies may have been disabled): #{exception}"

      render "pafs_core/errors/invalid_authenticity_token", status: :forbidden
    end

  end
end
