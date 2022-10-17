# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class HeathlandHabitatCreatedOrEnhancedStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      project.send(:hectares_of_heathland_created_or_enhanced=, nil) if step_params(params)[:heathland] == "false"

      super
    end

    private

    def step_params(params)
      params.require(:heathland_habitat_created_or_enhanced_step).permit(:heathland)
    end

    def a_choice_has_been_made
      return unless heathland.nil?

      errors.add(:heathland, "^You must select yes or no")
    end
  end
end
