# frozen_string_literal: true

module PafsCore
  class HectaresOfWetWoodlandHabitatCreatedOrEnhancedStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :amount_is_present_and_correct

    private

    def step_params(params)
      params
        .require(:hectares_of_wet_woodland_habitat_created_or_enhanced_step)
        .permit(:hectares_of_wet_woodland_habitat_created_or_enhanced)
    end

    def amount_is_present_and_correct
      if hectares_of_wet_woodland_habitat_created_or_enhanced.blank?
        errors.add(:hectares_of_wet_woodland_habitat_created_or_enhanced,
                   "^You must include the number of hectares "\
                   "your project will create.")
      elsif hectares_of_wet_woodland_habitat_created_or_enhanced <= 0
        errors.add(:hectares_of_wet_woodland_habitat_created_or_enhanced,
                   "^You must include the number of hectares "\
                   "your project will create.")
      end
    end
  end
end
