# frozen_string_literal: true

module PafsCore
  # This module provides placeholder methods for Bootstrap models
  # to enable them to work with services
  module BootstrapPlaceholders
    extend ActiveSupport::Concern

    # A null object that responds to ActiveRecord methods and always returns empty results
    class NullAssociation
      def where(*_args)
        self
      end

      def exists?
        false
      end

      def empty?
        true
      end

      def any?
        false
      end
    end

    def funding_values
      NullAssociation.new
    end

    def flood_protection_outcomes
      NullAssociation.new
    end

    def coastal_erosion_protection_outcomes
      NullAssociation.new
    end

    def flood_protection2040_outcomes
      NullAssociation.new
    end

    def earliest_start_year
      nil
    end

    def earliest_start_month
      nil
    end
  end
end
