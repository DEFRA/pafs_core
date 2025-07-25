# frozen_string_literal: true

require "roo"

module PafsCore
  class CalculatorParser
    include PafsCore::FundingCalculatorVersion

    attr_reader :sheet, :project

    PARSER_MAPS = {
      v8: PafsCore::CalculatorMaps::V8,
      v9: PafsCore::CalculatorMaps::V9
    }.freeze

    SHEET_NAMES = [
      "PF Calculator",
      "PF calculator"
    ].freeze

    def initialize(calculator, project)
      calculator_sheet_name = calculator.sheets.grep(/PF Calculator/i).first || raise("No calculator sheet found")
      @sheet = calculator.sheet(calculator_sheet_name)
      @project = project
    end

    def self.parse(file, project)
      raise "require an xlsx file" unless File.extname(file.path) == ".xlsx"

      begin
        calculator = Roo::Excelx.new(file.path)
        new(calculator, project).extract_data
      rescue StandardError => e
        Rails.logger.error "Error parsing calculator: #{e}"
        Airbrake.notify(e)
      end
    end

    def parser_map
      PARSER_MAPS[calculator_version] || raise("Unknown PFC version")
    end

    def data
      @data ||= parser_map.new(sheet).data
    end

    def extract_data
      project.update(data)
    end

    def binary_value?(value)
      value.casecmp("yes").zero?
    end
  end
end
