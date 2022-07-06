# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class WetlandOrWetGrasslandHabitatCreatedOrEnhancedStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      project.send(:hectares_of_wetland_or_wet_grassland_created_or_enhanced=, nil) if step_params(params)[:wetland_or_wet_grassland] == "false"

      super
    end

    private

    def step_params(params)
      params.require(:wetland_or_wet_grassland_habitat_created_or_enhanced_step).permit(:wetland_or_wet_grassland)
    end

    def a_choice_has_been_made
      if wetland_or_wet_grassland.nil?
        errors.add(:wetland_or_wet_grassland,
                   "^You must select yes or no")
      end
    end
  end
end
