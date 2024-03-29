# frozen_string_literal: true

module PafsCore
  SQL_COLUMNS_FOR_SPREADSHEET = %w[
    p.name
    reference_number
    project_end_financial_year
    region
    county
    parliamentary_constituency
    start_outline_business_case_month
    start_outline_business_case_year
    award_contract_month
    award_contract_year
    start_construction_month
    start_construction_year
    ready_for_service_month
    ready_for_service_year
    fcerm_gia
    local_levy
    internal_drainage_boards
    growth_funding
    not_yet_identified
    could_start_early
    earliest_start_month
    earliest_start_year
    fluvial_flooding
    tidal_flooding
    groundwater_flooding
    surface_water_flooding
    coastal_erosion
    main_risk
    project_type
    funding_calculator_file_name
    project_location
    flood_protection_before
    flood_protection_after
    coastal_protection_before
    coastal_protection_after
    urgency_reason
    urgency_details
    approach
    improve_surface_or_groundwater
    improve_surface_or_groundwater_amount
    improve_river
    improve_spa_or_sac
    improve_sssi
    improve_hpi
    improve_habitat_amount
    improve_river_amount
    create_habitat
    create_habitat_amount
    remove_fish_barrier
    remove_eel_barrier
    fish_or_eel_amount
    funding_sources_visited
    sea_flooding
    reservoir_flooding
    gia_list
    levy_list
    idb_list
    public_list
    private_list
    ea_list
    growth_list
    nyi_list
    total_list
    flood_households
    flood_households_moved
    flood_most_deprived
    coastal_households
    coastal_households_protected
    coastal_most_deprived
    strategic_approach
    raw_partnership_funding_score
    adjusted_partnership_funding_score
    pv_whole_life_costs
    pv_whole_life_benefits
    duration_of_benefits
    hectares_of_net_water_dependent_habitat_created
    hectares_of_net_water_intertidal_habitat_created
    kilometres_of_protected_river_improved
    public_contributions
    private_contributions
    other_ea_contributions
    public_contributor_names
    private_contributor_names
    other_ea_contributor_names
  ].freeze
end
