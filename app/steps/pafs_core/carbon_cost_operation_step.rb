# frozen_string_literal: true

module PafsCore
  class CarbonCostOperationStep < BasicStep
    include PafsCore::Carbon

    validates_numericality_of :carbon_cost_operation,
                              only_numeric: true,
                              allow_nil: true,
                              greater_than_or_equal_to: 0

    private

    def step_params(params)
      params
        .require(:carbon_cost_operation_step)
        .permit(
          :carbon_cost_operation
        )
    end
  end
end
