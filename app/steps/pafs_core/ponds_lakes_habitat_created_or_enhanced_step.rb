# frozen_string_literal: true

module PafsCore
  class PondsLakesHabitatCreatedOrEnhancedStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      if step_params(params)[:ponds_lakes] == "false"
        project.send(:hectares_of_pond_or_lake_habitat_created_or_enhanced=, nil)
      end

      super
    end

    private

    def step_params(params)
      params.require(:ponds_lakes_habitat_created_or_enhanced_step).permit(:ponds_lakes)
    end

    def a_choice_has_been_made
      return unless ponds_lakes.nil?

      errors.add(:ponds_lakes, "You must select yes or no")
    end
  end
end
