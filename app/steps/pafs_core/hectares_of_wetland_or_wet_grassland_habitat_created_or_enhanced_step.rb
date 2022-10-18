# frozen_string_literal: true

module PafsCore
  class HectaresOfWetlandOrWetGrasslandHabitatCreatedOrEnhancedStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :amount_is_present_and_correct

    private

    def step_params(params)
      params
        .require(:hectares_of_wetland_or_wet_grassland_habitat_created_or_enhanced_step)
        .permit(:hectares_of_wetland_or_wet_grassland_created_or_enhanced)
    end

    def amount_is_present_and_correct
      if hectares_of_wetland_or_wet_grassland_created_or_enhanced.blank? ||
         hectares_of_wetland_or_wet_grassland_created_or_enhanced <= 0
        errors.add(:hectares_of_wetland_or_wet_grassland_created_or_enhanced,
                   "^You must include the number of hectares " \
                   "your project will create.")
      end
    end
  end
end
