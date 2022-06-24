# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class AnyEnvironmentalBenefitsStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    private

    def step_params(params)
      params.require(:any_environmental_benefits_step).permit(:environmental_benefits)
    end

    def a_choice_has_been_made
      if environmental_benefits.nil?
        errors.add(:environmental_benefits,
                   "^You must select yes or no")
      end
    end
  end
end
