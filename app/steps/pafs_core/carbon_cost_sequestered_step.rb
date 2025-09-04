# frozen_string_literal: true

module PafsCore
  class CarbonCostSequesteredStep < BasicStep
    include PafsCore::Carbon

    validates_numericality_of :carbon_cost_sequestered,
                              only_numeric: true,
                              allow_nil: true,
                              greater_than_or_equal_to: 0

    private

    def step_params(params)
      params
        .require(:carbon_cost_sequestered_step)
        .permit(
          :carbon_cost_sequestered
        )
    end
  end
end
