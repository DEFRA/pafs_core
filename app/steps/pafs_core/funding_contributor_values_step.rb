# frozen_string_literal: true

module PafsCore
  class FundingContributorValuesStep < BasicStep
    include PafsCore::FundingValues

    delegate :funding_contributors,
             :funding_contributors_attributes,
             :funding_contributors_attributes=,
             to: :project

    validate :at_least_one_value?

    # override to allow us to set up the funding_values if needed
    def before_view(_params)
      setup_funding_values
    end

    def param_key
      :private_contributor_values_step
    end

    private

    def contributor_type
      PafsCore::FundingSources::PRIVATE_CONTRIBUTIONS
    end

    def at_least_one_value?
      contributors = funding_contributors.to_a.select do |x|
        x.contributor_type == contributor_type.to_s
      end.group_by(&:name)
      contributors = contributors.values.map { |v| v.map(&:amount).compact.reduce(&:+) }

      return true if contributors.none?(&:zero?)

      errors.add(:base, "Please ensure you enter at least one value for every contributor")
      false
    end

    def step_params(params)
      params.require(param_key).permit(
        funding_contributors_attributes: %i[
          id
          amount
          secured
          constrained
        ]
      )
    end
  end
end
