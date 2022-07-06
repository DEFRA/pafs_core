# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class WoodlandHabitatCreatedOrEnhancedStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      project.send(:hectares_of_woodland_habitat_created_or_enhanced=, nil) if step_params(params)[:woodland] == "false"

      super
    end

    private

    def step_params(params)
      params.require(:woodland_habitat_created_or_enhanced_step).permit(:woodland)
    end

    def a_choice_has_been_made
      if woodland.nil?
        errors.add(:woodland,
                   "^You must select yes or no")
      end
    end
  end
end
