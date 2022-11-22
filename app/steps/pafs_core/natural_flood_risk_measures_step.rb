# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class NaturalFloodRiskMeasuresStep < BasicStep
    include PafsCore::NaturalFloodRiskMeasures

    validate :at_least_one_flood_risk_measure_has_been_selected
    validate :other_flood_measure_has_been_added

    MEASURES = %i[
      river_restoration
      floodplain_restoration
      leaky_barriers
      offline_flood_storage_areas
      catchment_woodland
      cross_slope_woodland
      floodplain_woodland
      riparian_woodland
      soil_and_land_management
      land_and_headwater_drainage_management
      runoff_pathway_management
      saltmarsh_mudflats_and_managed_realignment
      sand_dunes
      beach_nourishment
      other_flood_measures
      other_flood_measures_selected
    ].freeze

    def update(params)
      if %w[0 false].include? step_params(params)[:other_flood_measures_selected]
        params[:natural_flood_risk_measures_step][:other_flood_measures] = nil
      end

      super
    end

    private

    def step_params(params)
      permitted_params = params.require(:natural_flood_risk_measures_step).permit(MEASURES)

      # ensure all measures not included in the selection are set to nil
      MEASURES.index_with { |m| permitted_params[m] }
    end

    def at_least_one_flood_risk_measure_has_been_selected
      return if selected_natural_flood_risk_measures.count.positive? || other_flood_measures.present?

      errors.add(:base, "The project must include at least one flood risk measure")
    end

    def other_flood_measure_has_been_added
      return unless other_flood_measures_selected

      return if other_flood_measures.present?

      errors.add(:other_flood_measures, "You must give your other flood risk measure a name")
    end
  end
end
