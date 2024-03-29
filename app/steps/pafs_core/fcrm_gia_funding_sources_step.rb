# frozen_string_literal: true

module PafsCore
  class FcrmGiaFundingSourcesStep < BasicStep
    FUNDING_SOURCES = PafsCore::FundingSources::FCRM_GIA_FUNDING_SOURCES

    include PafsCore::FundingSources
    include PafsCore::FundingValues

    delegate :funding_sources_visited, :funding_sources_visited=,
             :funding_sources_visited?,
             to: :project

    validate :at_least_one_funding_source_is_selected

    FUNDING_SOURCES.each do |fs|
      delegate fs, "#{fs}=", "#{fs}?", to: :project
    end

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
      return if params[:fcrm_gia_funding_sources_step].blank?

      params.require(:fcrm_gia_funding_sources_step).permit(FUNDING_SOURCES)
    end

    def at_least_one_funding_source_is_selected
      errors.add(:base, "The project must have at least one additional FCRM Grant in aid funding source.") unless
      [
        asset_replacement_allowance,
        environment_statutory_funding,
        frequently_flooded_communities,
        other_additional_grant_in_aid,
        other_government_department,
        recovery,
        summer_economic_fund
      ].any?(&:present?)
    end
  end
end
