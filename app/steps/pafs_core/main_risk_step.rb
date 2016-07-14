# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class MainRiskStep < BasicStep
    include PafsCore::Risks
    delegate :fluvial_flooding, :fluvial_flooding?,
             :tidal_flooding, :tidal_flooding?,
             :groundwater_flooding, :groundwater_flooding?,
             :surface_water_flooding, :surface_water_flooding?,
             :coastal_erosion, :coastal_erosion?,
             :main_risk, :main_risk=,
             :project_protects_households?,
             to: :project

    validate :main_risk_is_present_and_a_selected_risk

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = if protects_against_flooding?
                  :flood_protection_outcomes
                else
                  :coastal_erosion_protection_outcomes
                end
        true
      else
        false
      end
    end

    def previous_step
      :risks
    end

    def step
      @step ||= :main_risk
    end

    def disabled?
      !project_protects_households?
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:main_risk_step).permit(:main_risk)
    end

    def main_risk_is_present_and_a_selected_risk
      if main_risk.present?
        m = main_risk
        errors.add(:main_risk, "must be one of the selected risks") unless self.respond_to?(m) && self.send(m) == true
      else
        errors.add(:main_risk, "^A main source of risk must be selected")
      end
    end
  end
end
