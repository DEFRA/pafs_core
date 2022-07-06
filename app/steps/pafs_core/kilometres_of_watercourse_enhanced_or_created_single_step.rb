# frozen_string_literal: true

module PafsCore
  class KilometresOfWatercourseEnhancedOrCreatedSingleStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :amount_is_present_and_correct

    private

    def step_params(params)
      params
        .require(:kilometres_of_watercourse_enhanced_or_created_single_step)
        .permit(:kilometres_of_watercourse_enhanced_or_created_single)
    end

    def amount_is_present_and_correct
      if kilometres_of_watercourse_enhanced_or_created_single.blank?
        errors.add(:kilometres_of_watercourse_enhanced_or_created_single,
                    "^You must include the number of kilometres of watercourse "\
                    "the project will create.")
      elsif kilometres_of_watercourse_enhanced_or_created_single <= 0
        errors.add(:kilometres_of_watercourse_enhanced_or_created_single,
                    "^You must include the number of kilometres of watercourse "\
                    "the project will create.")
      end
    end
  end
end
