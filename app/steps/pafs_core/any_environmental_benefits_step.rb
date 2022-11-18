# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class AnyEnvironmentalBenefitsStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      reset_om4_attributes_to_nil if step_params(params)[:environmental_benefits] == "false"

      super
    end

    private

    def step_params(params)
      params.require(:any_environmental_benefits_step).permit(:environmental_benefits)
    end

    def a_choice_has_been_made
      return unless environmental_benefits.nil?

      errors.add(:environmental_benefits, "You must select yes or no")
    end

    def reset_om4_attributes_to_nil
      OM4_ATTRIBUTES.each do |om4_attribute|
        project.send("#{om4_attribute}=", nil)
      end
    end
  end
end
