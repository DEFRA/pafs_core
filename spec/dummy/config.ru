# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.
require "secure_headers"
use SecureHeaders::Middleware

require File.expand_path("config/environment", __dir__)
run Rails.application
