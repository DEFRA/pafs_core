# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class WetWoodlandHabitatCreatedOrEnhancedStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      if step_params(params)[:wet_woodland] == "false"
        project.send(:hectares_of_wet_woodland_habitat_created_or_enhanced=, nil)
      end

      super
    end

    private

    def step_params(params)
      params.require(:wet_woodland_habitat_created_or_enhanced_step).permit(:wet_woodland)
    end

    def a_choice_has_been_made
      return unless wet_woodland.nil?

      errors.add(:wet_woodland, "^You must select yes or no")
    end
  end
end
