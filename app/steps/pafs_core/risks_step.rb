# frozen_string_literal: true

module PafsCore
  class RisksStep < BasicStep
    include PafsCore::Risks
    delegate :project_protects_households?,
             to: :project

    validate :at_least_one_risk_is_selected

    RISK_ATTRIBUTES = %i[
      fluvial_flooding
      tidal_flooding
      groundwater_flooding
      surface_water_flooding
      sea_flooding
      reservoir_flooding
      coastal_erosion
    ].freeze

    def update(params)
      assign_attributes(all_risks(step_params(params)))
      if valid?
        self.main_risk = selected_risks.first.to_s if selected_risks.count == 1
        project.save
      else
        false
      end
    end

    private

    # ensure all risks not included in the selection are set to nil
    def all_risks(set_risks)
      default_risks = RISK_ATTRIBUTES.to_h { |ra| [ra.to_s, nil] }
      default_risks.merge(set_risks)
    end

    def step_params(params)
      params.require(:risks_step).permit(RISK_ATTRIBUTES)
    end

    def at_least_one_risk_is_selected
      errors.add(:base, "Select the risks your project protects against") unless
        selected_risks.count.positive?
    end
  end
end
