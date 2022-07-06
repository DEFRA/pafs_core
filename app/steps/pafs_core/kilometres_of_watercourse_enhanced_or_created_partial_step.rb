# frozen_string_literal: true

module PafsCore
  class KilometresOfWatercourseEnhancedOrCreatedPartialStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :amount_is_present_and_correct

    private

    def step_params(params)
      params
        .require(:kilometres_of_watercourse_enhanced_or_created_partial_step)
        .permit(:kilometres_of_watercourse_enhanced_or_created_partial)
    end

    def amount_is_present_and_correct
      if kilometres_of_watercourse_enhanced_or_created_partial.blank?
        errors.add(:kilometres_of_watercourse_enhanced_or_created_partial,
                   "^You must include the number of kilometres "\
                  "your project will create.")
      elsif kilometres_of_watercourse_enhanced_or_created_partial <= 0
        errors.add(:kilometres_of_watercourse_enhanced_or_created_partial,
                    "^You must include the number of kilometres "\
                    "your project will create.")
      end
    end
  end
end
