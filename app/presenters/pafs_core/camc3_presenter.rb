# frozen_string_literal: true

require "pafs_core/shapefile_serializer"

module PafsCore
  class Camc3Presenter
    def initialize(project:)
      self.project = project

      self.funding_sources_mapper = PafsCore::Mapper::FundingSources.new(project: project)
      self.fcerm1_presenter = PafsCore::SpreadsheetPresenter.new(project)
      self.fcerm1_mapper = PafsCore::Mapper::Fcerm1.new(project: fcerm1_presenter)
      self.pf_calculator_presenter = PafsCore::PartnershipFundingCalculatorPresenter.new(project: project)
    end

    def households_at_reduced_risk
      financial_years.collect do |year|
        {
          year: year,
          value: fcerm1_presenter.households_at_reduced_risk(year)
        }
      end
    end

    def moved_from_very_significant_and_significant_to_moderate_or_low
      financial_years.collect do |year|
        {
          year: year,
          value: fcerm1_presenter.moved_from_very_significant_and_significant_to_moderate_or_low(year)
        }
      end
    end

    def households_protected_from_loss_in_20_percent_most_deprived
      financial_years.collect do |year|
        {
          year: year,
          value: fcerm1_presenter.households_protected_from_loss_in_20_percent_most_deprived(year)
        }
      end
    end

    def households_protected_through_plp_measures
      financial_years.collect do |year|
        {
          year: year,
          value: fcerm1_presenter.households_protected_through_plp_measures(year)
        }
      end
    end

    def non_residential_properties
      financial_years.collect do |year|
        {
          year: year,
          value: fcerm1_presenter.non_residential_properties(year)
        }
      end
    end

    def households_at_reduced_risk_2040
      financial_years.collect do |year|
        {
          year: year,
          value: fcerm1_presenter.households_at_reduced_risk_2040(year)
        }
      end
    end

    def moved_from_very_significant_and_significant_to_moderate_or_low_2040
      financial_years.collect do |year|
        {
          year: year,
          value: fcerm1_presenter.moved_from_very_significant_and_significant_to_moderate_or_low_2040(year)
        }
      end
    end

    def households_protected_from_loss_in_20_percent_most_deprived_2040
      financial_years.collect do |year|
        {
          year: year,
          value: fcerm1_presenter.households_protected_from_loss_in_20_percent_most_deprived_2040(year)
        }
      end
    end

    def non_residential_properties_2040
      financial_years.collect do |year|
        {
          year: year,
          value: fcerm1_presenter.non_residential_properties_2040(year)
        }
      end
    end

    def coastal_households_at_reduced_risk
      financial_years.collect do |year|
        {
          year: year,
          value: fcerm1_presenter.coastal_households_at_reduced_risk(year)
        }
      end
    end

    def coastal_households_protected_from_loss_in_next_20_years
      financial_years.collect do |year|
        {
          year: year,
          value: fcerm1_presenter.coastal_households_protected_from_loss_in_next_20_years(year)
        }
      end
    end

    def coastal_households_protected_from_loss_in_20_percent_most_deprived
      financial_years.collect do |year|
        {
          year: year,
          value: fcerm1_presenter.coastal_households_protected_from_loss_in_20_percent_most_deprived(year)
        }
      end
    end

    def coastal_non_residential_properties
      financial_years.collect do |year|
        {
          year: year,
          value: fcerm1_presenter.coastal_non_residential_properties(year)
        }
      end
    end

    def base64_shapefile
      @base64_shapefile ||= PafsCore::ShapefileSerializer.serialize(project)
    end

    def attributes
      fcerm1_mapper.attributes
                   .merge(pf_calculator_presenter.attributes)
                   .merge(funding_sources_mapper.attributes)
                   .merge(
                     {
                       capital_carbon: fcerm1_presenter.carbon_cost_build,
                       carbon_lifecycle: fcerm1_presenter.carbon_cost_operation
                     }
                   )
                   .merge(
                     {
                       confidence: {
                         homes_better_protected: project.confidence_homes_better_protected,
                         homes_by_gateway_four: project.confidence_homes_by_gateway_four,
                         secured_partnership_funding: project.confidence_secured_partnership_funding
                       }
                     }
                   )
                   .merge(
                     {
                       national_grid_reference: project.grid_reference,
                       shapefile: base64_shapefile,
                       urgency_details: fcerm1_presenter.urgency_details,
                       outcome_measures: {
                         om2: households_at_reduced_risk,
                         om2b: moved_from_very_significant_and_significant_to_moderate_or_low,
                         om2c: households_protected_from_loss_in_20_percent_most_deprived,
                         om2d: households_protected_through_plp_measures,
                         om2nrp: non_residential_properties,
                         om2Ba: households_at_reduced_risk_2040,
                         om2Bb: moved_from_very_significant_and_significant_to_moderate_or_low_2040,
                         om2Bc: households_protected_from_loss_in_20_percent_most_deprived_2040,
                         om2Bnrp: non_residential_properties_2040,
                         om3: coastal_households_at_reduced_risk,
                         om3b: coastal_households_protected_from_loss_in_next_20_years,
                         om3c: coastal_households_protected_from_loss_in_20_percent_most_deprived,
                         om3nrp: coastal_non_residential_properties,
                         om4a: fcerm1_presenter.hectares_of_habitat_created_or_enhanced,
                         om4b: fcerm1_presenter.kilometres_of_watercourse_created_or_enhanced
                       },
                       natural_flood_risk_measures: {
                         river_restoration: project.river_restoration,
                         floodplain_restoration: project.floodplain_restoration,
                         leaky_barriers: project.leaky_barriers,
                         offline_flood_storage_areas: project.offline_flood_storage_areas,
                         cross_slope_woodland: project.cross_slope_woodland,
                         catchment_woodland: project.catchment_woodland,
                         riparian_woodland: project.riparian_woodland,
                         floodplain_woodland: project.floodplain_woodland,
                         soil_and_land_management: project.soil_and_land_management,
                         land_and_headwater_drainage_management: project.land_and_headwater_drainage_management,
                         runoff_pathway_management: project.runoff_pathway_management,
                         saltmarsh_mudflats_and_managed_realignment: project.saltmarsh_mudflats_and_managed_realignment,
                         sand_dunes: project.sand_dunes,
                         beach_nourishment: project.beach_nourishment,
                         other_flood_measures: project.other_flood_measures,
                         natural_flood_risk_measures_cost: project.natural_flood_risk_measures_cost
                       }
                     }
                   )
    end

    protected

    attr_accessor :project, :fcerm1_presenter, :pf_calculator_presenter, :fcerm1_mapper, :funding_sources_mapper

    def financial_years
      [-1] + (2015..project.project_end_financial_year).to_a
    end
  end
end
