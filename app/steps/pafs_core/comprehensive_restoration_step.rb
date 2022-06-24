# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class ComprehensiveRestorationStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    private

    def step_params(params)
      params.require(:comprehensive_restoration_step).permit(:comprehensive_restoration)
    end

    def a_choice_has_been_made
      if comprehensive_restoration.nil?
        errors.add(:comprehensive_restoration,
                   "^You must select yes or no")
      end
    end
  end
end
