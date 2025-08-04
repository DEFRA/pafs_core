# frozen_string_literal: true

module PafsCore
  class NetCarbonStep < BasicStep
    include PafsCore::Carbon

    def update(_params)
      # just progress to next step
      true
    end

    def net_carbon_required_fields_empty?
      project.carbon_cost_build.blank? &&
        project.carbon_cost_operation.blank? &&
        project.carbon_cost_sequestered.blank? &&
        project.carbon_cost_avoided.blank?
    end

    def carbon_impact_presenter
      @carbon_impact_presenter ||= PafsCore::CarbonImpactPresenter.new(project: project)
    end
  end
end
