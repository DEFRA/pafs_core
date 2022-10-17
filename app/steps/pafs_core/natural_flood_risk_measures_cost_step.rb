# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class NaturalFloodRiskMeasuresCostStep < BasicStep
    include PafsCore::NaturalFloodRiskMeasures

    validate :natural_flood_risk_measures_cost_entered

    private

    def step_params(params)
      params
        .require(:natural_flood_risk_measures_cost_step)
        .permit(:natural_flood_risk_measures_cost)
    end

    def natural_flood_risk_measures_cost_entered
      return unless natural_flood_risk_measures_cost.nil?

      errors.add(:base,
                 "You must include a total cost for your flood risk measures")
    end
  end
end
