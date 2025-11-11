# frozen_string_literal: true

module PafsCore
  class CarbonImpactStep < BasicStep
    include PafsCore::Carbon

    def update(_params)
      project.carbon_values_update_hexdigest

      true
    end

    def presenter
      @presenter ||= PafsCore::CarbonImpactPresenter.new(project: project)
    end
  end
end
