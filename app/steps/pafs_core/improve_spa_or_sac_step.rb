# frozen_string_literal: true
module PafsCore
  class ImproveSpaOrSacStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    # # override BasicStep#completed? to handle earliest_date step
    # def completed?
    #   return false if improve_spa_or_sac.nil?
    #
    #   if improve_spa_or_sac?
    #     PafsCore::ImproveHabitatAmountStep.new(project).completed?
    #   else
    #     PafsCore::ImproveSssiStep.new(project).completed?
    #   end
    # end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:improve_spa_or_sac_step).
        permit(:improve_spa_or_sac)
    end

    def a_choice_has_been_made
      errors.add(:improve_spa_or_sac,
                 "^Tell us if the project protects or improves a Special "\
                 "Protected Area or Special Area of Conservation") if improve_spa_or_sac.nil?
    end
  end
end
