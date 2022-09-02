# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class CreateHabitatWatercourseStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      project.send(:kilometres_of_watercourse_enhanced_or_created_single=, nil) if step_params(params)[:create_habitat_watercourse] == "false"

      super
    end

    private

    def step_params(params)
      params.require(:create_habitat_watercourse_step).permit(:create_habitat_watercourse)
    end

    def a_choice_has_been_made
      if create_habitat_watercourse.nil?
        errors.add(:create_habitat_watercourse,
                   "^You must select yes or no")
      end
    end
  end
end
