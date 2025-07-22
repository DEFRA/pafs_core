# frozen_string_literal: true

module PafsCore
  module FundingCalculatorVersion
    extend ActiveSupport::Concern

    class Check
      VERSION_MAP = {
        v8: { column: "B", row: 3, version_text: /^Version 8/ },
        v9: { column: "B", row: 4, version_text: /^Version 2: April 2022/ }
      }.freeze

      ACCEPTED_VERSIONS = {
        v9: "v2 2020"
      }.freeze

      attr_reader :sheet

      def initialize(sheet)
        @sheet = sheet
      end

      def calculator_version
        VERSION_MAP.each do |k, v|
          return k if sheet.cell(v[:column], v[:row]).to_s.match(v[:version_text])
        end

        nil
      end
    end

    included do
      def calculator_version
        @calculator_version ||= Check.new(sheet).calculator_version
      end

      def accepted_version_names
        Check::ACCEPTED_VERSIONS.map { |_k, v| v }.join(" or ")
      end

      def calculator_version_accepted?
        Check::ACCEPTED_VERSIONS.keys.include?(calculator_version)
      end
    end
  end
end
