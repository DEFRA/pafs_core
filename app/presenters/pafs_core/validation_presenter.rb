# frozen_string_literal: true
require "pafs_core/natural_flood_risk_measures"

module PafsCore
  class ValidationPresenter < PafsCore::ProjectSummaryPresenter
    include PafsCore::FundingSources
    include PafsCore::NaturalFloodRiskMeasures

    def complete?
      result = true
      articles_to_validate.each do |article|
        complete = send "#{article}_complete?"
        result &&= complete
      end
      result
    end

    def project_name_complete?
      # NOTE: currently has to be present before creation
      true
    end

    def project_type_complete?
      # NOTE: currently has to be present before creation
      true
    end

    def financial_year_complete?
      # NOTE: currently has to be present before creation
      true
    end

    def location_complete?
      if location_set? && benefit_area_file_uploaded?
        true
      else
        add_error(:location, "^Tell us the location of the project")
      end
    end

    def confidence_complete?
      return true if confidence_homes_better_protected.present? &&
                     confidence_homes_by_gateway_four.present? &&
                     confidence_secured_partnership_funding.present?

      add_error(:confidence, "^Tell us how confident you are in the project")
    end

    def carbon_complete?
      return true if carbon_cost_build.present? &&
                     (carbon_cost_build.to_i >= 0) &&
                     carbon_cost_operation.present? &&
                     (carbon_cost_operation.to_i >= 0)

      add_error(:carbon, "^Tell us about the carbon cost of the project")
    end

    def key_dates_complete?
      if start_outline_business_case_month.present? &&
         award_contract_month.present? &&
         start_construction_month.present? &&
         ready_for_service_month.present?
        true
      else
        add_error(:key_dates, "^Tell us the project's important dates")
      end
    end

    def funding_sources_complete?
      return true if funding_values_complete?

      add_error(:funding_sources, "^Tell us the project's funding sources and estimated spend")
    end

    def earliest_start_complete?
      if could_start_early.nil?
        add_error(:earliest_start, "^Tell us the earliest date the project can start")
      elsif could_start_early?
        if earliest_start_month.present? && earliest_start_year.present?
          true
        else
          add_error(:earliest_start, "^Tell us the earliest date the project can start")
        end
      else
        true
      end
    end

    def risks_complete?
      if selected_risks.any?
        if protects_against_multiple_risks?
          if main_risk.nil?
            risks_error
          elsif protects_against_flooding? && protects_against_coastal_erosion?
            check_flooding && check_coastal_erosion
          elsif protects_against_flooding?
            check_flooding
          else
            # this must be only protecting against coastal erosion to get here
            check_coastal_erosion
          end
        elsif protects_against_flooding?
          check_flooding
        else
          check_coastal_erosion
        end
      else
        risks_error
      end
    end

    def standard_of_protection_complete?
      if protects_against_flooding?
        if flood_protection_before.nil? || flood_protection_after.nil?
          return add_error(:standard_of_protection,
                           "^Tell us the standard of protection the project will provide")
        end
      end

      if protects_against_coastal_erosion?
        if coastal_protection_before.nil? || coastal_protection_after.nil?
          return add_error(:standard_of_protection,
                           "^Tell us the standard of protection the project will provide")
        end
      end
      true
    end

    def approach_complete?
      if approach.blank?
        add_error(:approach, "^Tell us how the project will achieve its goals")
      else
        true
      end
    end

    def environmental_outcomes_complete?
      return outcomes_error if environmental_benefits.nil?

      return true unless environmental_benefits?

      return false if selected_om4_attributes.empty?

      check_intertidal && check_woodland && check_wet_woodland && check_wetland_or_wet_grassland &&
      check_grassland && check_heathland && check_pond_or_lake && check_arable_land &&
      check_comprehensive_watercourse && check_partial_watercourse && check_single_watercourse
    end

    def check_intertidal
      return outcomes_error if intertidal_habitat.nil?

      return outcomes_error if intertidal_habitat? && hectares_of_intertidal_habitat_created_or_enhanced.nil?

      true
    end

    def check_woodland
      return outcomes_error if woodland.nil?

      return outcomes_error if woodland? && hectares_of_woodland_habitat_created_or_enhanced.nil?

      true
    end

    def check_wet_woodland
      return outcomes_error if wet_woodland.nil?

      return outcomes_error if wet_woodland? && hectares_of_wet_woodland_habitat_created_or_enhanced.nil?

      true
    end

    def check_wetland_or_wet_grassland
      return outcomes_error if wetland_or_wet_grassland.nil?

      return outcomes_error if wetland_or_wet_grassland? && hectares_of_wetland_or_wet_grassland_created_or_enhanced.nil?

      true
    end

    def check_grassland
      return outcomes_error if grassland.nil?

      return outcomes_error if grassland? && hectares_of_grassland_habitat_created_or_enhanced.nil?

      true
    end

    def check_heathland
      return outcomes_error if heathland.nil?

      return outcomes_error if heathland? && hectares_of_heathland_created_or_enhanced.nil?

      true
    end

    def check_pond_or_lake
      return outcomes_error if ponds_lakes.nil?

      return outcomes_error if ponds_lakes? && hectares_of_pond_or_lake_habitat_created_or_enhanced.nil?

      true
    end

    def check_arable_land
      return outcomes_error if arable_land.nil?

      return outcomes_error if arable_land? && hectares_of_arable_land_lake_habitat_created_or_enhanced.nil?

      true
    end

    def check_comprehensive_watercourse
      return outcomes_error if comprehensive_restoration.nil?

      return outcomes_error if comprehensive_restoration? && kilometres_of_watercourse_enhanced_or_created_comprehensive.nil?

      true
    end

    def check_partial_watercourse
      return outcomes_error if partial_restoration.nil?

      return outcomes_error if partial_restoration? && kilometres_of_watercourse_enhanced_or_created_partial.nil?

      true
    end

    def check_single_watercourse
      return outcomes_error if create_habitat_watercourse.nil?

      return outcomes_error if  create_habitat_watercourse? && kilometres_of_watercourse_enhanced_or_created_single.nil?

      true
    end

    def urgency_complete?
      if urgency_reason.nil?
        add_error(:urgency, "^Tell us whether the project is urgent")
      elsif urgent? && urgency_details.blank?
        add_error(:urgency, "^Tell us whether the project is urgent")
      else
        true
      end
    end

    def funding_calculator_complete?
      if funding_calculator_file_name.blank?
        add_error(:funding_calculator, "^Upload the project's partnership funding calculator")
      else
        true
      end
    end

    def articles_to_validate
      if project_protects_households?
        all_articles
      else
        all_articles - %i[risks standard_of_protection]
      end
    end

    def funding_values_complete?
      return false unless selected_funding_sources.present?

      selected_funding_sources.all? { |fs| total_for(fs) > 0 }
    end

    def add_error(attr, msg)
      project.errors.add(attr, msg)
      false
    end

    def outcomes_error
      add_error(:environmental_outcomes,
                "^Tell us the project’s environmental outcomes")
    end

    def check_flooding
      if flooding_total_protected_households > 0 || project.reduced_risk_of_households_for_floods?
        true
      else
        risks_error
      end
    end

    def check_coastal_erosion
      if coastal_total_protected_households > 0 || project.reduced_risk_of_households_for_coastal_erosion?
        true
      else
        risks_error
      end
    end

    def natural_flood_risk_measures_complete?
      return true if project.natural_flood_risk_measures_included == false

      return true if project.natural_flood_risk_measures_included? && natural_flood_risk_measures_and_cost_provided?

      add_error(:natural_flood_risk_measures, "^Tell us about the project's natural flood risk measures")
    end

    def natural_flood_risk_measures_and_cost_provided?
      (selected_natural_flood_risk_measures.count > 0 || !project.other_flood_measures.blank?) && !project.natural_flood_risk_measures_cost.nil?
    end

    def risks_error
      add_error(:risks,
                "^Tell us the risks the project protects against "\
                "and the households benefiting.")
      false
    end
  end
end
