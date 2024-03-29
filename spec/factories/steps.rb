# frozen_string_literal: true

FactoryBot.define do
  factory :basic_step, class: "PafsCore::BasicStep" do
    project
    initialize_with { new(project) }

    after(:build) do |object|
      object.project.valid?
    end

    factory :project_name_step, class: "PafsCore::ProjectNameStep" do
      name { "My fantastic flood prevention scheme" }
    end

    factory :project_area_step, class: "PafsCore::ProjectAreaStep" do
      rma_name { "PSO Wessex" }
    end

    factory :project_type_step, class: "PafsCore::ProjectTypeStep" do
      project_type { PafsCore::PROJECT_TYPES.first }
    end

    factory :financial_year_step, class: "PafsCore::FinancialYearStep" do
      project_end_financial_year { Time.zone.today.year }
    end

    factory :financial_year_alternative_step, class: "PafsCore::FinancialYearAlternativeStep" do
      project_end_financial_year { Time.zone.today.uk_financial_year + 1 }
    end

    factory :key_dates_step, class: "PafsCore::KeyDatesStep" do
    end

    factory :start_outline_business_case_date_step, class: "PafsCore::StartOutlineBusinessCaseDateStep" do
      start_outline_business_case_month { 2 }
      start_outline_business_case_year { 2012 }
    end

    factory :complete_outline_business_case_date_step, class: "PafsCore::CompleteOutlineBusinessCaseDateStep" do
      complete_outline_business_case_month { 3 }
      complete_outline_business_case_year { 2013 }
    end

    factory :award_contract_date_step, class: "PafsCore::AwardContractDateStep" do
      award_contract_month { 4 }
      award_contract_year { 2014 }
    end

    factory :start_construction_date_step, class: "PafsCore::StartConstructionDateStep" do
      start_construction_month { 5 }
      start_construction_year { 2015 }
    end

    factory :ready_for_service_date_step, class: "PafsCore::ReadyForServiceDateStep" do
      ready_for_service_month { 9 }
      ready_for_service_year { 3.years.from_now.year }
    end

    factory :funding_sources_step, class: "PafsCore::FundingSourcesStep" do
      fcerm_gia { true }
      funding_sources_visited { true }
    end

    factory :fcrm_gia_funding_sources_step, class: "PafsCore::FcrmGiaFundingSourcesStep" do
      asset_replacement_allowance { true }
    end

    factory :could_start_sooner_step, class: "PafsCore::CouldStartSoonerStep" do
      could_start_early { true }
    end

    factory :earliest_start_date_step, class: "PafsCore::EarliestStartDateStep" do
      earliest_start_month { 3 }
      earliest_start_year { 2017 }
    end

    factory :earliest_start_date_with_gia_step, class: "PafsCore::EarliestStartDateWithGiaStep" do
      earliest_with_gia_month { 4 }
      earliest_with_gia_year { 2018 }
    end

    factory :risks_step, class: "PafsCore::RisksStep" do
      fluvial_flooding { true }
    end

    factory :main_risk_step, class: "PafsCore::MainRiskStep" do
      main_risk { "fluvial_flooding" }
    end

    factory :location_step, class: "PafsCore::LocationStep" do
      grid_reference { "SK0071972583" }
      region { "North West" }
      county { "Greater Manchester" }
      parliamentary_constituency { "Manchester Central" }
    end

    factory :benefit_area_file_step, class: "PafsCore::BenefitAreaFileStep" do
    end

    factory :map_step, class: "PafsCore::MapStep" do
      benefit_area { "[[432123, 132453], [444444, 134444], [456543, 123432]]" }
      benefit_area_centre { [457_733, 221_751] }
      benefit_area_zoom_level { 23 }
      benefit_area_file_name { "shapefile.zip" }
    end

    factory :benefit_area_file_summary_step, class: "PafsCore::BenefitAreaFileSummaryStep" do
    end

    factory :standard_of_protection_step, class: "PafsCore::StandardOfProtectionStep" do
      flood_protection_before { 1 }
    end

    factory :standard_of_protection_after_step, class: "PafsCore::StandardOfProtectionAfterStep" do
      flood_protection_after { 2 }
    end

    factory :standard_of_protection_coastal_step, class: "PafsCore::StandardOfProtectionCoastalStep" do
      coastal_protection_before { 0 }
    end

    factory :standard_of_protection_coastal_after_step, class: "PafsCore::StandardOfProtectionCoastalAfterStep" do
      coastal_protection_after { 3 }
    end

    factory :approach_step, class: "PafsCore::ApproachStep" do
      approach { "We will go left and then turn right for a bit" }
    end

    factory :urgency_step, class: "PafsCore::UrgencyStep" do
      urgency_reason { "health_and_safety" }
      urgency_details { "This is the description" }
    end

    factory :urgency_details_step, class: "PafsCore::UrgencyDetailsStep" do
      urgency_details { "This is the description" }
    end

    factory :funding_calculator_step, class: "PafsCore::FundingCalculatorStep" do
      funding_calculator_file_name { "pf_calc.xls" }
    end

    factory :funding_calculator_summary_step, class: "PafsCore::FundingCalculatorSummaryStep" do
    end

    factory :confidence_homes_better_protected_step, class: "PafsCore::ConfidenceHomesBetterProtectedStep" do
      confidence_homes_better_protected { "high" }
    end

    factory :confidence_homes_by_gateway_four_step, class: "PafsCore::ConfidenceHomesByGatewayFourStep" do
      confidence_homes_by_gateway_four { "high" }
    end

    factory :confidence_secured_partnership_funding_step, class: "PafsCore::ConfidenceSecuredPartnershipFundingStep" do
      confidence_secured_partnership_funding { "high" }
    end

    factory :natural_flood_risk_measures_step, class: "PafsCore::NaturalFloodRiskMeasuresStep" do
      river_restoration { true }
    end

    factory :natural_flood_risk_measures_included_step, class: "PafsCore::NaturalFloodRiskMeasuresIncludedStep" do
      natural_flood_risk_measures_included { true }
    end

    factory :natural_flood_risk_measures_cost_step, class: "PafsCore::NaturalFloodRiskMeasuresCostStep" do
      natural_flood_risk_measures_cost { 12.23 }
    end

    factory :any_environmental_benefits_step, class: "PafsCore::AnyEnvironmentalBenefitsStep" do
      environmental_benefits { true }
    end

    factory :intertidal_habitat_created_or_enhanced_step, class: "PafsCore::IntertidalHabitatCreatedOrEnhancedStep" do
      intertidal_habitat { true }
    end

    factory :hectares_of_intertidal_habitat_created_or_enhanced_step, class: "PafsCore::HectaresOfIntertidalHabitatCreatedOrEnhancedStep" do
      hectares_of_intertidal_habitat_created_or_enhanced { 12 }
    end

    factory :woodland_habitat_created_or_enhanced_step, class: "PafsCore::WoodlandHabitatCreatedOrEnhancedStep" do
      woodland { true }
    end

    factory :hectares_of_woodland_habitat_created_or_enhanced_step, class: "PafsCore::HectaresOfWoodlandHabitatCreatedOrEnhancedStep" do
      hectares_of_woodland_habitat_created_or_enhanced { 12 }
    end

    factory :wet_woodland_habitat_created_or_enhanced_step, class: "PafsCore::WetWoodlandHabitatCreatedOrEnhancedStep" do
      wet_woodland { true }
    end

    factory :hectares_of_wet_woodland_habitat_created_or_enhanced_step, class: "PafsCore::HectaresOfWetWoodlandHabitatCreatedOrEnhancedStep" do
      hectares_of_wet_woodland_habitat_created_or_enhanced { 12 }
    end

    factory :wetland_or_wet_grassland_habitat_created_or_enhanced_step, class: "PafsCore::WetlandOrWetGrasslandHabitatCreatedOrEnhancedStep" do
      wetland_or_wet_grassland { true }
    end

    factory :hectares_of_wetland_or_wet_grassland_habitat_created_or_enhanced_step, class: "PafsCore::HectaresOfWetlandOrWetGrasslandHabitatCreatedOrEnhancedStep" do
      hectares_of_wetland_or_wet_grassland_created_or_enhanced { 12 }
    end

    factory :grassland_habitat_created_or_enhanced_step, class: "PafsCore::GrasslandHabitatCreatedOrEnhancedStep" do
      grassland { true }
    end

    factory :hectares_of_grassland_habitat_created_or_enhanced_step, class: "PafsCore::HectaresOfGrasslandHabitatCreatedOrEnhancedStep" do
      hectares_of_grassland_habitat_created_or_enhanced { 12 }
    end

    factory :heathland_habitat_created_or_enhanced_step, class: "PafsCore::HeathlandHabitatCreatedOrEnhancedStep" do
      heathland { true }
    end

    factory :hectares_of_heathland_created_or_enhanced_step, class: "PafsCore::HectaresOfHeathlandCreatedOrEnhancedStep" do
      hectares_of_heathland_created_or_enhanced { 12 }
    end

    factory :ponds_lakes_habitat_created_or_enhanced_step, class: "PafsCore::PondsLakesHabitatCreatedOrEnhancedStep" do
      ponds_lakes { true }
    end

    factory :hectares_of_pond_or_lake_habitat_created_or_enhanced_step, class: "PafsCore::HectaresOfPondOrLakeHabitatCreatedOrEnhancedStep" do
      hectares_of_pond_or_lake_habitat_created_or_enhanced { 12 }
    end

    factory :arable_land_created_or_enhanced_step, class: "PafsCore::ArableLandCreatedOrEnhancedStep" do
      arable_land { true }
    end

    factory :hectares_of_arable_land_lake_habitat_created_or_enhanced_step, class: "PafsCore::HectaresOfArableLandLakeHabitatCreatedOrEnhancedStep" do
      hectares_of_arable_land_lake_habitat_created_or_enhanced { 12 }
    end

    factory :comprehensive_restoration_step, class: "PafsCore::ComprehensiveRestorationStep" do
      comprehensive_restoration { true }
    end

    factory :kilometres_of_watercourse_enhanced_or_created_comprehensive_step, class: "PafsCore::KilometresOfWatercourseEnhancedOrCreatedComprehensiveStep" do
      kilometres_of_watercourse_enhanced_or_created_comprehensive { 12 }
    end

    factory :partial_restoration_step, class: "PafsCore::PartialRestorationStep" do
      partial_restoration { true }
    end

    factory :kilometres_of_watercourse_enhanced_or_created_partial_step, class: "PafsCore::KilometresOfWatercourseEnhancedOrCreatedPartialStep" do
      kilometres_of_watercourse_enhanced_or_created_partial { 12 }
    end

    factory :create_habitat_watercourse_step, class: "PafsCore::CreateHabitatWatercourseStep" do
      create_habitat_watercourse { true }
    end

    factory :kilometres_of_watercourse_enhanced_or_created_single_step, class: "PafsCore::KilometresOfWatercourseEnhancedOrCreatedSingleStep" do
      kilometres_of_watercourse_enhanced_or_created_single { 12 }
    end
  end
end
