# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class NaturalFloodRiskMeasuresIncludedStep < BasicStep
    include PafsCore::NaturalFloodRiskMeasures

    validate :a_choice_has_been_made

    def update(params)
      reset_natural_flood_risk_measure_attributes_to_nil if step_params(params)[:natural_flood_risk_measures_included] == "false"

      super
    end

    private

    def step_params(params)
      params
        .require(:natural_flood_risk_measures_included_step)
        .permit(:natural_flood_risk_measures_included)
    end

    def a_choice_has_been_made
      if natural_flood_risk_measures_included.nil?
        errors.add(:natural_flood_risk_measures_included,
                   "You must select yes or no")
      end
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