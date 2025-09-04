# frozen_string_literal: true

module PafsCore
  class CarbonCostAvoidedStep < BasicStep
    include PafsCore::Carbon

    validates_numericality_of :carbon_cost_avoided,
                              only_numeric: true,
                              allow_nil: true,
                              greater_than_or_equal_to: 0

    private

    def step_params(params)
      params
        .require(:carbon_cost_avoided_step)
        .permit(
          :carbon_cost_avoided
        )
    end
  end
end
