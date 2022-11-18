# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class IntertidalHabitatCreatedOrEnhancedStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      if step_params(params)[:intertidal_habitat] == "false"
        project.send(:hectares_of_intertidal_habitat_created_or_enhanced=, nil)
      end

      super
    end

    private

    def step_params(params)
      params.require(:intertidal_habitat_created_or_enhanced_step).permit(:intertidal_habitat)
    end

    def a_choice_has_been_made
      return unless intertidal_habitat.nil?

      errors.add(:intertidal_habitat, "You must select yes or no")
    end
  end
end
