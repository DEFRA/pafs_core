# frozen_string_literal: true

module PafsCore
  class FcermGiaFundingSourcesStep < FundingSourcesStep
    FUNDING_SOURCES = %i[
      asset_replacement_allowance
      environmental_statutory_funding
      frequently_flooded_communities
      other additional_grant_in_aid
      other_government_department
      recovery
      summer_economic_fund
    ].freeze

    def update(params)
      binding.pry
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
