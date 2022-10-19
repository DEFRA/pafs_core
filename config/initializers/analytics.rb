# frozen_string_literal: true

# Google Analytics
Rails.configuration.analytics_tracking_id = ENV.fetch("GA_VIEW_ID", nil)
