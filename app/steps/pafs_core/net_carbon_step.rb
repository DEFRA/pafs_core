# frozen_string_literal: true

module PafsCore
  class NetCarbonStep < BasicStep
    include PafsCore::Carbon

    def update(_params)
      # just progress to next step
      true
    end

    def presenter
      @presenter ||= PafsCore::CarbonImpactPresenter.new(project: project)
    end
  end
end
