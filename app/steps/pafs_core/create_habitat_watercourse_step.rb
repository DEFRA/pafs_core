# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class CreateHabitatWatercourseStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

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
