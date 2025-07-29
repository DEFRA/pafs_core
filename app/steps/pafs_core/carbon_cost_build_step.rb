# frozen_string_literal: true

module PafsCore
  class CarbonCostBuildStep < BasicStep
    include PafsCore::Carbon

    validates :carbon_cost_build,
              numericality: {
                greater_than_or_equal_to: 0,
                only_integer: false
              },
              unless: -> { carbon_cost_build.blank? }

    private

    def step_params(params)
      params
        .require(:carbon_cost_build_step)
        .permit(
          :carbon_cost_build
        )
    end
  end
end
