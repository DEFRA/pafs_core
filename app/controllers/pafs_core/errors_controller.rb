# frozen_string_literal: true

module PafsCore
  class ErrorsController < PafsCore::ApplicationController
    def show
      @exception = ENV.fetch("action_dispatch.exception", nil)
      action = request.path[1..].gsub(/[^0-9]/, "")
      action = 500 if action.blank?

      status_code =
        if @exception
          trace = Rails.backtrace_cleaner.clean(@exception.backtrace)
          Rails.logger.fatal "Fatal error: #{trace.join('#\n')}"

          ActionDispatch::ExceptionWrapper.new(ENV, @exception).status_code
        else
          action.to_i
        end

      respond_to do |format|
        format.html { render action: action, status: status_code }
        format.json { render json: { status: status_code, error: @exception.message } }
      end
    end
  end
end
