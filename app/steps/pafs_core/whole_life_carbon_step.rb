# frozen_string_literal: true

module PafsCore
  class WholeLifeCarbonStep < BasicStep
    include PafsCore::Carbon

    def update(_params)
      # just progress to next step
      true
    end

    def whole_life_carbon_required_fields_empty?
      project.carbon_cost_build.blank? &&
        project.carbon_cost_operation.blank?
    end

    def carbon_impact_presenter
      @carbon_impact_presenter ||= PafsCore::CarbonImpactPresenter.new(project: project)
    end
  end
end
