# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class PartialRestorationStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      project.send(:kilometres_of_watercourse_enhanced_or_created_partial=, nil) if step_params(params)[:partial_restoration] == "false"

      super
    end

    private

    def step_params(params)
      params.require(:partial_restoration_step).permit(:partial_restoration)
    end

    def a_choice_has_been_made
      if partial_restoration.nil?
        errors.add(:partial_restoration,
                   "^You must select yes or no")
      end
    end
  end
end
