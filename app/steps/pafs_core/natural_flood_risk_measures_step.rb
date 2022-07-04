# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class NaturalFloodRiskMeasuresStep < BasicStep
    include PafsCore::NaturalFloodRiskMeasures

    validate :at_least_one_flood_risk_measure_has_been_selected
    validate :other_flood_measure_has_been_added

    def update(params)
      params[:natural_flood_risk_measures_step][:other_flood_measures] = nil if ["0", "false"].include? step_params(params)[:other_flood_measures_selected]

      super
    end

    private

    def step_params(params)
      params
        .require(:natural_flood_risk_measures_step)
        .permit(:river_restoration,
                :floodplain_restoration,
                :leaky_barriers,
                :offline_flood_storage_areas,
                :catchment_woodland,
                :cross_slope_woodland,
                :floodplain_woodland,
                :riparian_woodland,
                :soil_and_land_management,
                :land_and_headwater_drainage_management,
                :runoff_pathway_management,
                :saltmarsh_mudflats_and_managed_realignment,
                :sand_dunes,
                :beach_nourishment,
                :other_flood_measures,
                :other_flood_measures_selected
              )
    end

    def at_least_one_flood_risk_measure_has_been_selected
      return if selected_natural_flood_risk_measures.count > 0 || !other_flood_measures.blank?

      errors.add(:base, "The project must include at least one flood risk measure")
    end

    def other_flood_measure_has_been_added
      return unless other_flood_measures_selected

      errors.add(:other_flood_measures, "^You must give your other flood risk measure a name") if other_flood_measures.blank?
    end
  end
end