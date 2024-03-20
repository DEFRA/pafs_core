# frozen_string_literal: true

require "pafs_core/natural_flood_risk_measures"

module PafsCore
  class ValidationPresenter < PafsCore::ProjectSummaryPresenter
    include PafsCore::FundingSources
    include PafsCore::NaturalFloodRiskMeasures
    include PafsCore::Files
    include PafsCore::FundingCalculatorVersion

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
        add_error(:location, "Tell us the location of the project")
      end
    end

    def confidence_complete?
      return true if confidence_homes_better_protected.present? &&
                     confidence_homes_by_gateway_four.present? &&
                     confidence_secured_partnership_funding.present?

      add_error(:confidence, "Tell us how confident you are in the project")
    end

    def carbon_complete?
      return true if carbon_cost_build.present? &&
                     (carbon_cost_build.to_i >= 0) &&
                     carbon_cost_operation.present? &&
                     (carbon_cost_operation.to_i >= 0)

      add_error(:carbon, "Tell us about the carbon cost of the project")
    end

    def key_dates_complete?
      # ensure all dates are present and start_outline_business_case is in the future
      if start_outline_business_case_year.present? &&
         start_outline_business_case_month.present? &&
         award_contract_year.present? &&
         award_contract_month.present? &&
         start_construction_year.present? &&
         start_construction_month.present? &&
         ready_for_service_year.present? &&
         ready_for_service_month.present?
        check_key_dates_in_future &&
          check_key_dates_within_project_lifetime_range &&
          check_funding_values_within_project_lifetime_range &&
          check_outcomes_within_project_lifetime_range &&
          check_outcomes_2040_within_project_lifetime_range &&
          check_coastal_outcomes_within_project_lifetime_range
      else
        add_error(:key_dates, "Tell us the project's important dates")
      end
    end

    def check_key_dates_in_future
      if date_in_future?("start_outline_business_case")
        true
      else
        add_error(:key_dates,
                  "The record will remain in draft. " \
                  "One or more of the dates entered in your 'Important Dates’ section is in the past, " \
                  "please revise and resubmit your proposal.")
      end
    end

    def check_key_dates_within_project_lifetime_range
      if date_within_project_lifetime_range?("ready_for_service")
        true
      else
        add_error(:key_dates,
                  I18n.t("pafs_core.validation_presenter.errors.key_dates_outside_project_lifetime"))
      end
    end

    def check_funding_values_within_project_lifetime_range
      all_non_aggr_non_removed_funding_sources = PafsCore::FundingSources::ALL_FUNDING_SOURCES -
                                                 PafsCore::FundingSources::REMOVED_FROM_FUNDING_VALUES -
                                                 PafsCore::FundingSources::AGGREGATE_SOURCES

      err_count = 0
      funding_values.each do |fv|
        # ignore past financial years
        next if fv.financial_year == -1
        # check if any of the funding sources has a value
        next if all_non_aggr_non_removed_funding_sources.reduce(0) { |sum, fs| sum + fv.send(fs).to_i }.zero? &&
                fv.public_contributions.reduce(0) { |sum, pc| sum + pc.amount.to_i }.zero? &&
                fv.private_contributions.reduce(0) { |sum, pc| sum + pc.amount.to_i }.zero? &&
                fv.other_ea_contributions.reduce(0) { |sum, pc| sum + pc.amount.to_i }.zero?

        # check if the financial year is within the project lifetime range
        next if fv.financial_year >= earliest_start_year && fv.financial_year <= project_end_financial_year

        add_error(:funding_sources,
                  I18n.t("pafs_core.validation_presenter.errors.funding_data_outside_project_lifetime"))
        err_count += 1
      end

      err_count.zero?
    end

    def check_outcomes_within_project_lifetime_range
      all_outcome_columns = %i[
        households_at_reduced_risk
        moved_from_very_significant_and_significant_to_moderate_or_low
        households_protected_from_loss_in_20_percent_most_deprived
        households_protected_through_plp_measures
        non_residential_properties
      ]

      err_count = 0
      flood_protection_outcomes.each do |fpo|
        # ignore past financial years
        next if fpo.financial_year == -1
        # check if any of the protection outcomes has a value
        next if all_outcome_columns.reduce(0) { |sum, aoc| sum + fpo.send(aoc).to_i }.zero?

        # check if the financial year is within the project lifetime range
        next if fpo.financial_year >= earliest_start_year && fpo.financial_year <= project_end_financial_year

        add_error(:risks,
                  I18n.t("pafs_core.validation_presenter.errors.outcome_outside_project_lifetime"))
        err_count += 1
      end

      err_count.zero?
    end

    def check_outcomes_2040_within_project_lifetime_range
      all_outcome_columns = %i[
        households_at_reduced_risk
        moved_from_very_significant_and_significant_to_moderate_or_low
        households_protected_from_loss_in_20_percent_most_deprived
        non_residential_properties
      ]

      err_count = 0
      flood_protection2040_outcomes.each do |fpo|
        # ignore past financial years
        next if fpo.financial_year == -1
        # check if any of the protection outcomes has a value
        next if all_outcome_columns.reduce(0) { |sum, aoc| sum + fpo.send(aoc).to_i }.zero?

        # check if the financial year is within the project lifetime range
        next if fpo.financial_year >= earliest_start_year && fpo.financial_year <= project_end_financial_year

        add_error(:risks,
                  I18n.t("pafs_core.validation_presenter.errors.outcome_outside_project_lifetime"))
        err_count += 1
      end

      err_count.zero?
    end

    def check_coastal_outcomes_within_project_lifetime_range
      all_outcome_columns = %i[
        households_at_reduced_risk
        households_protected_from_loss_in_next_20_years
        households_protected_from_loss_in_20_percent_most_deprived
        non_residential_properties
      ]

      err_count = 0
      coastal_erosion_protection_outcomes.each do |cepo|
        # ignore past financial years
        next if cepo.financial_year == -1
        # check if any of the protection outcomes has a value
        next if all_outcome_columns.reduce(0) { |sum, aoc| sum + cepo.send(aoc).to_i }.zero?

        # check if the financial year is within the project lifetime range
        next if cepo.financial_year >= earliest_start_year && cepo.financial_year <= project_end_financial_year

        add_error(:risks,
                  I18n.t("pafs_core.validation_presenter.errors.outcome_outside_project_lifetime"))
        err_count += 1
      end

      err_count.zero?
    end

    def funding_sources_complete?
      return true if funding_values_complete?

      add_error(:funding_sources, "Tell us the project's funding sources and estimated spend")
    end

    def earliest_start_complete?
      if mandatory_earliest_start_fields_missing? || (could_start_early? && additional_earliest_start_fields_missing?)
        add_earliest_start_error
      end

      if (date_present?("earliest_start") && !date_in_future?("earliest_start")) ||
         (date_present?("earliest_with_gia") && !date_in_future?("earliest_with_gia"))
        add_earliest_start_in_the_past_error
      end

      errors.count.zero?
    end

    def check_earliest_start_in_future
      if date_in_future?("earliest_start")
        true
      else
        add_earliest_start_in_the_past_error
      end
    end

    def mandatory_earliest_start_fields_missing?
      (earliest_start_month.blank? || earliest_start_year.blank?) || could_start_early.nil?
    end

    def additional_earliest_start_fields_missing?
      earliest_with_gia_month.blank? || earliest_with_gia_year.blank?
    end

    def add_earliest_start_error
      add_error(:earliest_start, "Tell us the earliest date the project can start")
    end

    def add_earliest_start_in_the_past_error
      add_error(:earliest_start,
                "The record will remain in draft. " \
                "One or more of the dates entered in your 'Earliest start’ section is in the past, " \
                "please revise and resubmit your proposal.")
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
      if protects_against_flooding? &&
         (flood_protection_before.nil? || flood_protection_after.nil?)
        return add_error(:standard_of_protection,
                         "Tell us the standard of protection the project will provide")
      end

      if protects_against_coastal_erosion? &&
         (coastal_protection_before.nil? || coastal_protection_after.nil?)
        return add_error(:standard_of_protection,
                         "Tell us the standard of protection the project will provide")
      end
      true
    end

    def approach_complete?
      if approach.blank?
        add_error(:approach, "Tell us how the project will achieve its goals")
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

      return outcomes_error if wetland_or_wet_grassland? &&
                               hectares_of_wetland_or_wet_grassland_created_or_enhanced.nil?

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

      return outcomes_error if comprehensive_restoration? &&
                               kilometres_of_watercourse_enhanced_or_created_comprehensive.nil?

      true
    end

    def check_partial_watercourse
      return outcomes_error if partial_restoration.nil?

      return outcomes_error if partial_restoration? && kilometres_of_watercourse_enhanced_or_created_partial.nil?

      true
    end

    def check_single_watercourse
      return outcomes_error if create_habitat_watercourse.nil?

      return outcomes_error if create_habitat_watercourse? && kilometres_of_watercourse_enhanced_or_created_single.nil?

      true
    end

    def urgency_complete?
      if urgency_reason.nil? || (urgent? && urgency_details.blank?)
        add_error(:urgency, "Tell us whether the project is urgent")
      else
        true
      end
    end

    def funding_calculator_complete?
      if funding_calculator_file_name.blank?
        return add_error(:funding_calculator, "Upload the project's partnership funding calculator")
      end

      unless funding_calculator_correct_version?
        return add_error(:funding_calculator, "Upload a valid version of the partnership funding calculator")
      end

      true
    end

    def articles_to_validate
      if project_protects_households?
        all_articles
      else
        all_articles - %i[risks standard_of_protection]
      end
    end

    def funding_values_complete?
      return false if selected_funding_sources.blank?

      selected_funding_sources.all? { |fs| total_for(fs).positive? }
    end

    def add_error(attr, msg)
      project.errors.add(attr, msg)
      false
    end

    def outcomes_error
      add_error(:environmental_outcomes,
                "Tell us the project’s environmental outcomes")
    end

    def check_flooding
      if flooding_total_protected_households.positive? || project.reduced_risk_of_households_for_floods?
        true
      else
        risks_error
      end
    end

    def check_coastal_erosion
      if coastal_total_protected_households.positive? || project.reduced_risk_of_households_for_coastal_erosion?
        true
      else
        risks_error
      end
    end

    def natural_flood_risk_measures_complete?
      return true if project.natural_flood_risk_measures_included == false

      return true if project.natural_flood_risk_measures_included? && natural_flood_risk_measures_and_cost_provided?

      add_error(:natural_flood_risk_measures, "Tell us about the project's natural flood risk measures")
    end

    def natural_flood_risk_measures_and_cost_provided?
      (selected_natural_flood_risk_measures.count.positive? || project.other_flood_measures.present?) &&
        !project.natural_flood_risk_measures_cost.nil?
    end

    def risks_error
      add_error(:risks,
                "Tell us the risks the project protects against " \
                "and the households benefitting.")
      false
    end

    private

    def date_within_project_lifetime_range?(date_name)
      column_year = send("#{date_name}_year").to_i
      column_month = send("#{date_name}_month").to_i

      date_later_than?(date_name, "earliest_start") &&
        Date.new(column_year, column_month, 1) < Date.new(project_end_financial_year, 3, 1)
    end

    def funding_calculator_correct_version?
      tfile = Tempfile.new(["funding_calculator", ".xlsx"])
      tfile.write File.read fetch_funding_calculator_for(project).path
      xlsx = Roo::Spreadsheet.open tfile.path
      sheet = xlsx.sheet(xlsx.sheets.grep(/PF Calculator/i).first)
      calculator_version = Check.new(sheet).calculator_version

      tfile.unlink

      Check::VERSION_MAP.include? calculator_version
    end
  end
end
