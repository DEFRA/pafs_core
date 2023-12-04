# frozen_string_literal: true

module PafsCore
  SPREADSHEET_BASIC_INFO = %i[
    name
    reference_number
    lrma_project_reference
    ldw_cpw_idb_number
    region
    rfcc
    ea_area
    lead_rma
    lead_rma_type
    coastal_group
    project_type
    main_risk
    urgency_reason
    packages
    grid_ref
    project_location
    county
    parliamentary_constituency
    parliamentary_constituencies_benefit_area
    agreed_strategy
    approach
    environmental_considerations
  ].freeze

  SPREADSHEET_STANDARD_OF_PROTECTION = %i[
    flood_protection_before
    flood_protection_after
    coastal_protection_before
    coastal_protection_after
    new_builds
  ].freeze

  SPREADSHEET_PF_CALCULATOR_FIGURES = %i[
    strategic_approach
    raw_partnership_funding_score
    adjusted_partnership_funding_score
    pv_whole_life_costs
    pv_whole_life_benefits
    pv_whole_life_benefit_cost_ratio
    duration_of_benefits
    scheme_comments
  ].freeze

  SPREADSHEET_WFD_INFO = %i[
    improve_sssi_spa_or_sac
    remove_fish_or_eel_barrier
    improve_surface_or_groundwater_amount
    improve_habitat_amount
    improve_river_amount
    fish_or_eel_amount
    create_habitat_amount
    additional_potential
    additional_funding_required_for_additional_benefits
  ].freeze

  SPREADSHEET_DATES = %i[
    earliest_start
    start_outline_business_case
    award_contract
    start_construction
    ready_for_service
  ].freeze

  SPREADSHEET_TOTALS = %i[
    gia_total
    levy_total
    idb_total
    public_total
    private_total
    ea_total
    growth_total
    nyi_total
    total_total
    flood_households_total
    flood_households_moved_total
    flood_most_deprived_total
    coastal_households_total
    coastal_households_protected_total
    coastal_most_deprived_total
    hectares_of_net_water_dependent_habitat_created
    hectares_of_net_water_intertidal_habitat_created
    kilometres_of_protected_river_improved
  ].freeze

  SPREADSHEET_SIX_YEAR_TOTALS = %i[
    gia_six_year_total
    contributions_six_year_total
    total_six_year_total
    households_six_year_total
  ].freeze

  SPREADSHEET_GIA_FIGURES = %i[
    gia_2023
    gia_2024
    gia_2025
    gia_2026
    gia_2027
    gia_2028
    gia_2029
    gia_2030
    gia_2031
    gia_2032
  ].freeze

  SPREADSHEET_LEVY_FIGURES = %i[
    levy_2023
    levy_2024
    levy_2025
    levy_2026
    levy_2027
    levy_2028
    levy_2029
    levy_2030
    levy_2031
    levy_2032
  ].freeze

  SPREADSHEET_IDB_FIGURES = %i[
    idb_2023
    idb_2024
    idb_2025
    idb_2026
    idb_2027
    idb_2028
    idb_2029
    idb_2030
    idb_2031
    idb_2032
  ].freeze

  SPREADSHEET_PUBLIC_FIGURES = %i[
    public_2023
    public_2024
    public_2025
    public_2026
    public_2027
    public_2028
    public_2029
    public_2030
    public_2031
    public_2032
  ].freeze

  SPREADSHEET_PRIVATE_FIGURES = %i[
    private_2023
    private_2024
    private_2025
    private_2026
    private_2027
    private_2028
    private_2029
    private_2030
    private_2031
    private_2032
  ].freeze

  SPREADSHEET_EA_FIGURES = %i[
    ea_2023
    ea_2024
    ea_2025
    ea_2026
    ea_2027
    ea_2028
    ea_2029
    ea_2030
    ea_2031
    ea_2032
  ].freeze

  SPREADSHEET_GROWTH_FIGURES = %i[
    growth_2023
    growth_2024
    growth_2025
    growth_2026
    growth_2027
    growth_2028
    growth_2029
    growth_2030
    growth_2031
    growth_2032
  ].freeze

  SPREADSHEET_NYI_FIGURES = %i[
    nyi_2023
    nyi_2024
    nyi_2025
    nyi_2026
    nyi_2027
    nyi_2028
    nyi_2029
    nyi_2030
    nyi_2031
    nyi_2032
  ].freeze

  SPREADSHEET_TOTAL_FIGURES = %i[
    total_2023
    total_2024
    total_2025
    total_2026
    total_2027
    total_2028
    total_2029
    total_2030
    total_2031
    total_2032
  ].freeze

  SPREADSHEET_COASTAL_FIGURES = %i[
    coastal_households_2023
    coastal_households_2024
    coastal_households_2025
    coastal_households_2026
    coastal_households_2027
    coastal_households_2028
    coastal_households_2029
    coastal_households_2030
    coastal_households_2031
    coastal_households_2032
    coastal_households_protected_2023
    coastal_households_protected_2024
    coastal_households_protected_2025
    coastal_households_protected_2026
    coastal_households_protected_2027
    coastal_households_protected_2028
    coastal_households_protected_2029
    coastal_households_protected_2030
    coastal_households_protected_2031
    coastal_households_protected_2032
    coastal_most_deprived_2023
    coastal_most_deprived_2024
    coastal_most_deprived_2025
    coastal_most_deprived_2026
    coastal_most_deprived_2027
    coastal_most_deprived_2028
    coastal_most_deprived_2029
    coastal_most_deprived_2030
    coastal_most_deprived_2031
    coastal_most_deprived_2032
  ].freeze

  SPREADSHEET_FUTURE_FIGURES = %i[
    gia_future_total
    total_future_total
    future_contributions_total
    future_households_total
  ].freeze

  SPREADSHEET_FLOODING_FIGURES = %i[
    flood_households_2023
    flood_households_2024
    flood_households_2025
    flood_households_2026
    flood_households_2027
    flood_households_2028
    flood_households_2029
    flood_households_2030
    flood_households_2031
    flood_households_2032
    flood_households_moved_2023
    flood_households_moved_2024
    flood_households_moved_2025
    flood_households_moved_2026
    flood_households_moved_2027
    flood_households_moved_2028
    flood_households_moved_2029
    flood_households_moved_2030
    flood_households_moved_2031
    flood_households_moved_2032
    flood_most_deprived_2023
    flood_most_deprived_2024
    flood_most_deprived_2025
    flood_most_deprived_2026
    flood_most_deprived_2027
    flood_most_deprived_2028
    flood_most_deprived_2029
    flood_most_deprived_2030
    flood_most_deprived_2031
    flood_most_deprived_2032
  ].freeze

  SPREADSHEET_OM4_COLUMNS = %i[
    hectares_of_net_water_dependent_habitat_created_2023
    hectares_of_net_water_dependent_habitat_created_2024
    hectares_of_net_water_dependent_habitat_created_2025
    hectares_of_net_water_dependent_habitat_created_2026
    hectares_of_net_water_dependent_habitat_created_2027
    hectares_of_net_water_dependent_habitat_created_2028
    hectares_of_net_water_dependent_habitat_created_2029
    hectares_of_net_water_dependent_habitat_created_2030
    hectares_of_net_water_dependent_habitat_created_2031
    hectares_of_net_water_dependent_habitat_created_2032
    hectares_of_net_water_intertidal_habitat_created_2023
    hectares_of_net_water_intertidal_habitat_created_2024
    hectares_of_net_water_intertidal_habitat_created_2025
    hectares_of_net_water_intertidal_habitat_created_2026
    hectares_of_net_water_intertidal_habitat_created_2027
    hectares_of_net_water_intertidal_habitat_created_2028
    hectares_of_net_water_intertidal_habitat_created_2029
    hectares_of_net_water_intertidal_habitat_created_2030
    hectares_of_net_water_intertidal_habitat_created_2031
    hectares_of_net_water_intertidal_habitat_created_2032
    kilometres_of_protected_river_improved_2023
    kilometres_of_protected_river_improved_2024
    kilometres_of_protected_river_improved_2025
    kilometres_of_protected_river_improved_2026
    kilometres_of_protected_river_improved_2027
    kilometres_of_protected_river_improved_2028
    kilometres_of_protected_river_improved_2029
    kilometres_of_protected_river_improved_2030
    kilometres_of_protected_river_improved_2031
    kilometres_of_protected_river_improved_2032
  ].freeze

  SPREADSHEET_UNUSED_COLUMNS = %i[
    packages
    ldw_cpw_idb_number
    lrma_project_reference
    parliamentary_constituencies_benefit_area
    agreed_strategy
    environmental_considerations
    new_builds
    scheme_comments
    additional_potential
    additional_funding_required_for_additional_benefits
    hectares_of_net_water_dependent_habitat_created_2023
    hectares_of_net_water_dependent_habitat_created_2024
    hectares_of_net_water_dependent_habitat_created_2025
    hectares_of_net_water_dependent_habitat_created_2026
    hectares_of_net_water_dependent_habitat_created_2027
    hectares_of_net_water_dependent_habitat_created_2028
    hectares_of_net_water_dependent_habitat_created_2029
    hectares_of_net_water_dependent_habitat_created_2030
    hectares_of_net_water_dependent_habitat_created_2031
    hectares_of_net_water_dependent_habitat_created_2032
    hectares_of_net_water_intertidal_habitat_created_2023
    hectares_of_net_water_intertidal_habitat_created_2024
    hectares_of_net_water_intertidal_habitat_created_2025
    hectares_of_net_water_intertidal_habitat_created_2026
    hectares_of_net_water_intertidal_habitat_created_2027
    hectares_of_net_water_intertidal_habitat_created_2028
    hectares_of_net_water_intertidal_habitat_created_2029
    hectares_of_net_water_intertidal_habitat_created_2030
    hectares_of_net_water_intertidal_habitat_created_2031
    hectares_of_net_water_intertidal_habitat_created_2032
    kilometres_of_protected_river_improved_2023
    kilometres_of_protected_river_improved_2024
    kilometres_of_protected_river_improved_2025
    kilometres_of_protected_river_improved_2026
    kilometres_of_protected_river_improved_2027
    kilometres_of_protected_river_improved_2028
    kilometres_of_protected_river_improved_2029
    kilometres_of_protected_river_improved_2030
    kilometres_of_protected_river_improved_2031
    kilometres_of_protected_river_improved_2032
  ].freeze

  SPREADSHEET_ADDITIONAL_COLUMNS = %i[
    project_executive
    project_manager
    project_record_owner
    project_status
    finance_category
    additional_function
    public_contributor_names
    private_contributor_names
    other_ea_contributor_names
  ].freeze

  SPREADSHEET_COLUMN_ORDER = [
    SPREADSHEET_BASIC_INFO,
    SPREADSHEET_STANDARD_OF_PROTECTION,
    SPREADSHEET_PF_CALCULATOR_FIGURES,
    SPREADSHEET_DATES,
    SPREADSHEET_TOTALS,
    SPREADSHEET_TOTAL_FIGURES,
    SPREADSHEET_GIA_FIGURES,
    SPREADSHEET_GROWTH_FIGURES,
    SPREADSHEET_LEVY_FIGURES,
    SPREADSHEET_IDB_FIGURES,
    SPREADSHEET_PUBLIC_FIGURES,
    SPREADSHEET_PRIVATE_FIGURES,
    SPREADSHEET_EA_FIGURES,
    SPREADSHEET_NYI_FIGURES,
    SPREADSHEET_FLOODING_FIGURES,
    SPREADSHEET_COASTAL_FIGURES,
    SPREADSHEET_OM4_COLUMNS,
    SPREADSHEET_WFD_INFO,
    SPREADSHEET_FUTURE_FIGURES,
    SPREADSHEET_SIX_YEAR_TOTALS,
    SPREADSHEET_ADDITIONAL_COLUMNS
  ].flatten.freeze
end
