# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class ArableLandCreatedOrEnhancedStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      if step_params(params)[:arable_land] == "false"
        project.send(:hectares_of_arable_land_lake_habitat_created_or_enhanced=, nil)
      end

      super
    end

    private

    def step_params(params)
      params.require(:arable_land_created_or_enhanced_step).permit(:arable_land)
    end

    def a_choice_has_been_made
      return unless arable_land.nil?

      errors.add(:arable_land, "You must select yes or no")
    end
  end
end
