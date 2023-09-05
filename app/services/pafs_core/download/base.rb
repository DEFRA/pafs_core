# frozen_string_literal: true

module PafsCore
  module Download
    class Base
      include PafsCore::Files

      def initialize(_opts = nil); end

      # Robocop and SonarCloud disagree over the use of arguments forwarding
      # rubocop:disable Style/ArgumentsForwarding
      def self.perform(*opts)
        new(*opts).tap(&:perform)
      end
      # rubocop:enable Style/ArgumentsForwarding

      def perform
        raise("Override #perform in subclass")
      end
    end
  end
end
