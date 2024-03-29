# frozen_string_literal: true

module PafsCore
  class CouldStartSoonerStep < BasicStep
    delegate :could_start_early, :could_start_early=, :could_start_early?,
             to: :project

    validate :a_choice_has_been_made

    private

    def step_params(params)
      params.require(:could_start_sooner_step).permit(:could_start_early)
    end

    def a_choice_has_been_made
      errors.add(:could_start_early, "Tell us if the project can start earlier") if could_start_early.nil?
    end
  end
end
