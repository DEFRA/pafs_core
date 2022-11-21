# frozen_string_literal: true

module PafsCore
  class KilometresOfWatercourseEnhancedOrCreatedComprehensiveStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :amount_is_present_and_correct

    private

    def step_params(params)
      params
        .require(:kilometres_of_watercourse_enhanced_or_created_comprehensive_step)
        .permit(:kilometres_of_watercourse_enhanced_or_created_comprehensive)
    end

    def amount_is_present_and_correct
      if kilometres_of_watercourse_enhanced_or_created_comprehensive.blank? ||
         kilometres_of_watercourse_enhanced_or_created_comprehensive <= 0
        errors.add(:kilometres_of_watercourse_enhanced_or_created_comprehensive,
                   "You must include the number of kilometres " \
                   "your project will create.")
      end
    end
  end
end
