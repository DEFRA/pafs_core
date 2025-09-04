# frozen_string_literal: true

module PafsCore
  class FloodProtectionOutcomes2040SummaryStep < BasicStep
    include PafsCore::Risks
    include PafsCore::Outcomes

    delegate :project_protects_households?,
             to: :project

    def update(_params)
      # do nothing
      true
    end
  end
end
