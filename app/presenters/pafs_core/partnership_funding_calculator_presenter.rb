# frozen_string_literal: true

module PafsCore
  class PartnershipFundingCalculatorPresenter
    include PafsCore::Files

    attr_accessor :project, :mapper, :pv_appraisal_approach

    def initialize(project:)
      fetch_funding_calculator_for(project) do |data, filename, _content_type|
        file = Tempfile.new(filename)
        file.write(data)
        file.rewind

        self.mapper = PafsCore::Mapper::PartnershipFundingCalculator.new(calculator_file: file)
        attributes

        file.close
      end
    end

    def attributes
      return PafsCore::Mapper::PartnershipFundingCalculator.default_attributes if mapper.nil?

      mapper.attributes
    end
  end
end
