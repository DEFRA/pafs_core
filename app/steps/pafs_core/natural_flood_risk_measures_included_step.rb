# frozen_string_literal: true

module PafsCore
  class NaturalFloodRiskMeasuresIncludedStep < BasicStep
    include PafsCore::NaturalFloodRiskMeasures

    validate :a_choice_has_been_made

    def update(params)
      if step_params(params)[:natural_flood_risk_measures_included] == "false"
        reset_natural_flood_risk_measure_attributes_to_nil
      end

      super
    end

    private

    def step_params(params)
      params
        .require(:natural_flood_risk_measures_included_step)
        .permit(:natural_flood_risk_measures_included)
    end

    def a_choice_has_been_made
      return unless natural_flood_risk_measures_included.nil?

      errors.add(:natural_flood_risk_measures_included, "You must select yes or no")
    end

    def reset_natural_flood_risk_measure_attributes_to_nil
      selected_natural_flood_risk_measures.each do |risk_measure|
        project.send("#{risk_measure}=", nil)
      end

      project.send("other_flood_measures=", nil)
      project.send("other_flood_measures_selected=", nil)
      project.send("natural_flood_risk_measures_cost=", nil)
    end
  end
end
