# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class GrasslandHabitatCreatedOrEnhancedStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      if step_params(params)[:grassland] == "false"
        project.send(:hectares_of_grassland_habitat_created_or_enhanced=, nil)
      end

      super
    end

    private

    def step_params(params)
      params.require(:grassland_habitat_created_or_enhanced_step).permit(:grassland)
    end

    def a_choice_has_been_made
      return unless grassland.nil?

      errors.add(:grassland, "You must select yes or no")
    end
  end
end
