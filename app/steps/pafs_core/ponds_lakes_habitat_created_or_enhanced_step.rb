# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class PondsLakesHabitatCreatedOrEnhancedStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    private

    def step_params(params)
      params.require(:ponds_lakes_habitat_created_or_enhanced_step).permit(:ponds_lakes)
    end

    def a_choice_has_been_made
      if ponds_lakes.nil?
        errors.add(:ponds_lakes,
                   "^You must select yes or no")
      end
    end
  end
end
