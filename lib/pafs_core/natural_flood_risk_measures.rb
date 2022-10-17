# frozen_string_literal: true

module PafsCore
  module NaturalFloodRiskMeasures
    NATURAL_FLOOD_RISK_MEASURES = %i[
      river_restoration
      floodplain_restoration
      leaky_barriers
      offline_flood_storage_areas
      cross_slope_woodland
      catchment_woodland
      riparian_woodland
      floodplain_woodland
      soil_and_land_management
      land_and_headwater_drainage_management
      runoff_pathway_management
      saltmarsh_mudflats_and_managed_realignment
      sand_dunes
      beach_nourishment
    ].freeze

    NATURAL_FLOOD_RISK_MEASURES.each do |r|
      delegate r, "#{r}=", "#{r}?", to: :project
    end
    delegate :other_flood_measures_selected,
             :other_flood_measures_selected=,
             :other_flood_measures,
             :other_flood_measures=,
             :natural_flood_risk_measures_included,
             :natural_flood_risk_measures_included=,
             :natural_flood_risk_measures_included?,
             :natural_flood_risk_measures_cost,
             :natural_flood_risk_measures_cost=,
             to: :project

    def selected_natural_flood_risk_measures
      NATURAL_FLOOD_RISK_MEASURES.select { |r| send("#{r}?") }
    end

    def natural_flood_risk_measures_started?
      !natural_flood_risk_measures_included.nil?
    end

    def risk_from_string(str)
      I18n.t("pafs_core.fcerm1.risks").invert[str]
    end
  end
end
