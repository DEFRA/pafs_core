# frozen_string_literal: true

module PafsCore
  class WholeLifeCarbonStep < BasicStep
    include PafsCore::Carbon

    def update(_params)
      # just progress to next step
      true
    end
  end
end
