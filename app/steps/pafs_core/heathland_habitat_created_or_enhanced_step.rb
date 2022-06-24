# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class HeathlandHabitatCreatedOrEnhancedStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    private

    def step_params(params)
      params.require(:heathland_habitat_created_or_enhanced_step).permit(:heathland)
    end

    def a_choice_has_been_made
      if heathland.nil?
        errors.add(:heathland,
                   "^You must select yes or no")
      end
    end
  end
end
