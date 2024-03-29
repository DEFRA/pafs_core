# frozen_string_literal: true

module PafsCore
  class FundingSourcesStep < BasicStep
    include PafsCore::FundingSources
    include PafsCore::FundingValues

    delegate :funding_sources_visited, :funding_sources_visited=,
             :funding_sources_visited?,
             to: :project

    validate :at_least_one_funding_source_is_selected

    FUNDING_SOURCES = %i[
      fcerm_gia
      local_levy
      internal_drainage_boards
      public_contributions
      private_contributions
      other_ea_contributions
      growth_funding
      not_yet_identified
    ].freeze

    def update(params)
      assign_attributes(all_funding_sources(step_params(params) || {}).merge(funding_sources_visited: true))
      clean_unselected_funding_sources
      funding_values.reject(&:destroyed?).map(&:save!)

      valid? && project.save
    end

    private

    # ensure all sources not included in the selection are set to nil
    def all_funding_sources(set_sources)
      FUNDING_SOURCES.to_h { |fs| [fs.to_s, set_sources[fs]] }
    end

    def step_params(params)
      params.require(:funding_sources_step).permit(FUNDING_SOURCES) if params[:funding_sources_step].present?
    end

    def at_least_one_funding_source_is_selected
      errors.add(:base, "The project must have at least one funding source.") unless
        [fcerm_gia,
         local_levy,
         internal_drainage_boards,
         public_contributions,
         private_contributions,
         other_ea_contributions,
         growth_funding,
         not_yet_identified].any?(&:present?)
    end
  end
end
