# frozen_string_literal: true

module PafsCore
  class NetCarbonBenefitStep < BasicStep
    include PafsCore::Carbon

    validates_numericality_of :carbon_savings_net_economic_benefit,
                              only_numeric: true,
                              allow_nil: true

    private

    def step_params(params)
      params
        .require(:net_carbon_benefit_step)
        .permit(
          :carbon_savings_net_economic_benefit
        )
    end
  end
end
