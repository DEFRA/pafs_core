# frozen_string_literal: true

module PafsCore
  SPREADSHEET_COLUMN_HEADERS = {
    name: "Project Name",
    reference_number: "National Project Number",
    project_type: "Project Type",
    approach: "Brief Description of Problem and Proposed Solution",
    urgency_reason: "Moderation Code",
    main_risk: "Risk Source",
    region: "ONS Region",
    parliamentary_constituency: "Parliamentary Constituencies - Project Location",
    improve_surface_or_groundwater_amount: "Kilometres of WFD water body protected improved",
    improve_sssi_spa_or_sac:
    "Does project address a Water Framework Directive protected areas,\
    eg Special Areas of Conservation, Special Protection Areas",
    improve_habitat_amount: "Hectares of habitat (including SSSI) protected or improved",
    improve_river_amount: "Kilometres of river habitat (including SSSI) protected or improved",
    create_habitat_amount: "Hectares of habitat created",
    remove_fish_or_eel_barrier: "Does project remove a barrier to migration for fish or eels?",
    fish_or_eel_amount: "Kilometres of water body opened up to fish or eel passage",
    flood_protection_before: "Flooding Schemes Standard of Protection - before Construction %",
    flood_protection_after: "Flooding Schemes Standard of Protection - after Construction %",
    coastal_protection_before: "Coastal Erosion Schemes Standard of Protection - before Construction Yrs",
    coastal_protection_after: "Coastal Erosion Schemes Standard of Protection - after Construction Yrs",
    rfcc: "RFCC",
    coastal_group: "Coastal Group",
    lead_rma: "Lead Risk Management Authority - Name",
    lead_rma_type: "Lead Risk Management Authority - Type",
    grid_ref: "National Grid Reference",
    project_location: "Project Location (Town, River, SSSI etc)",
    ea_area: "EA Area",
    gia_total: "GiA - PROJECT TOTAL",
    levy_total: "Local Levy - PROJECT TOTAL",
    idb_total: "IDB - PROJECT TOTAL",
    public_total: "Public - PROJECT TOTAL",
    private_total: "Public - PROJECT TOTAL",
    ea_total: "Other EA - PROJECT TOTAL",
    growth_total: "Growth - PROJECT TOTAL",
    nyi_total: "Further required - PROJECT TOTAL",
    total_total: "TPE - PROJECT TOTAL",
    flood_households_total: "OM2 - PROJECT TOTAL",
    flood_households_moved_total: "OM2b - PROJECT TOTAL",
    flood_most_deprived_total: "OM2c - PROJECT TOTAL",
    coastal_households_total: "OM3 - PROJECT TOTAL",
    coastal_households_protected_total: "OM3b - PROJECT TOTAL",
    coastal_most_deprived_total: "OM3c - PROJECT TOTAL",
    gia_six_year_total: "GiA 6 year total",
    contributions_six_year_total: "Contributions 6 year total",
    total_six_year_total: "TPE 6 year total",
    households_six_year_total: "OM2+3 6 year total",
    gia_previous_years: "GiA - PREVIOUS YEARS",
    gia_2015: "GiA - 2015/16",
    gia_2016: "GiA - 2016/17",
    gia_2017: "GiA - 2017/18",
    gia_2018: "GiA - 2018/19",
    gia_2019: "GiA - 2019/20",
    gia_2020: "GiA - 2020/21",
    gia_2021: "GiA - 2021/22",
    gia_2022: "GiA - 2022/23",
    gia_2023: "GiA - 2023/24",
    gia_2024: "GiA - 2024/25",
    gia_2025: "GiA - 2025/26",
    gia_2026: "GiA - 2026/27",
    gia_2027: "GiA - 2027/28 on",
    levy_previous_years: "Local Levy - PREVIOUS YEARS",
    levy_2015: "Local Levy - 2015/16",
    levy_2016: "Local Levy - 2016/17",
    levy_2017: "Local Levy - 2017/18",
    levy_2018: "Local Levy - 2018/19",
    levy_2019: "Local Levy - 2019/20",
    levy_2020: "Local Levy - 2020/21",
    levy_2021: "Local Levy - 2021/22",
    levy_2022: "Local Levy - 2022/23",
    levy_2023: "Local Levy - 2023/24",
    levy_2024: "Local Levy - 2024/25",
    levy_2025: "Local Levy - 2025/26",
    levy_2026: "Local Levy - 2026/27",
    levy_2027: "Local Levy - 2027/28 on",
    idb_previous_years: "IDB - PREVIOUS YEARS",
    idb_2015: "IDB - 2015/16",
    idb_2016: "IDB - 2016/17",
    idb_2017: "IDB - 2017/18",
    idb_2018: "IDB - 2018/19",
    idb_2019: "IDB - 2019/20",
    idb_2020: "IDB - 2020/21",
    idb_2021: "IDB - 2021/22",
    idb_2022: "IDB - 2022/23",
    idb_2023: "IDB - 2023/24",
    idb_2024: "IDB - 2024/25",
    idb_2025: "IDB - 2025/26",
    idb_2026: "IDB - 2026/27",
    idb_2027: "IDB - 2027/28 on",
    public_previous_years: "Public - PREVIOUS YEARS",
    public_2015: "Public - 2015/16",
    public_2016: "Public - 2016/17",
    public_2017: "Public - 2017/18",
    public_2018: "Public - 2018/19",
    public_2019: "Public - 2019/20",
    public_2020: "Public - 2020/21",
    public_2021: "Public - 2021/22",
    public_2022: "Public - 2022/23",
    public_2023: "Public - 2023/24",
    public_2024: "Public - 2024/25",
    public_2025: "Public - 2025/26",
    public_2026: "Public - 2026/27",
    public_2027: "Public - 2027/28 on",
    private_previous_years: "Private - PREVIOUS YEARS",
    private_2015: "Private - 2015/16",
    private_2016: "Private - 2016/17",
    private_2017: "Private - 2017/18",
    private_2018: "Private - 2018/19",
    private_2019: "Private - 2019/20",
    private_2020: "Private - 2020/21",
    private_2021: "Private - 2021/22",
    private_2022: "Private - 2022/23",
    private_2023: "Private - 2023/24",
    private_2024: "Private - 2024/25",
    private_2025: "Private - 2025/26",
    private_2026: "Private - 2026/27",
    private_2027: "Private - 2027/28 on",
    ea_previous_years: "Other EA - PREVIOUS YEARS",
    ea_2015: "Other EA - 2015/16",
    ea_2016: "Other EA - 2016/17",
    ea_2017: "Other EA - 2017/18",
    ea_2018: "Other EA - 2018/19",
    ea_2019: "Other EA - 2019/20",
    ea_2020: "Other EA - 2020/21",
    ea_2021: "Other EA - 2021/22",
    ea_2022: "Other EA - 2022/23",
    ea_2023: "Other EA - 2023/24",
    ea_2024: "Other EA - 2024/25",
    ea_2025: "Other EA - 2025/26",
    ea_2026: "Other EA - 2026/27",
    ea_2027: "Other EA - 2027/28 on",
    growth_previous_years: "Growth - PREVIOUS YEARS",
    growth_2015: "Growth - 2015/16",
    growth_2016: "Growth - 2016/17",
    growth_2017: "Growth - 2017/18",
    growth_2018: "Growth - 2018/19",
    growth_2019: "Growth - 2019/20",
    growth_2020: "Growth - 2020/21",
    growth_2021: "Growth - 2021/22",
    growth_2022: "Growth - 2022/23",
    growth_2023: "Growth - 2023/24",
    growth_2024: "Growth - 2024/25",
    growth_2025: "Growth - 2025/26",
    growth_2026: "Growth - 2026/27",
    growth_2027: "Growth - 2027/28 on",
    nyi_previous_years: "Further required - PREVIOUS YEARS",
    nyi_2015: "Further required - 2015/16",
    nyi_2016: "Further required - 2016/17",
    nyi_2017: "Further required - 2017/18",
    nyi_2018: "Further required - 2018/19",
    nyi_2019: "Further required - 2019/20",
    nyi_2020: "Further required - 2020/21",
    nyi_2021: "Further required - 2021/22",
    nyi_2022: "Further required - 2022/23",
    nyi_2023: "Further required - 2023/24",
    nyi_2024: "Further required - 2024/25",
    nyi_2025: "Further required - 2025/26",
    nyi_2026: "Further required - 2026/27",
    nyi_2027: "Further required - 2027/28 on",
    total_previous_years: "TPE - PREVIOUS YEARS",
    total_2015: "TPE - 2015/16",
    total_2016: "TPE - 2016/17",
    total_2017: "TPE - 2017/18",
    total_2018: "TPE - 2018/19",
    total_2019: "TPE - 2019/20",
    total_2020: "TPE - 2020/21",
    total_2021: "TPE - 2021/22",
    total_2022: "TPE - 2022/23",
    total_2023: "TPE - 2023/24",
    total_2024: "TPE - 2024/25",
    total_2025: "TPE - 2025/26",
    total_2026: "TPE - 2026/27",
    total_2027: "TPE - 2027/28 on",
    coastal_households_previous_years: "OM3 - PREVIOUS YEARS",
    coastal_households_2015: "OM3 - 2015/16",
    coastal_households_2016: "OM3 - 2016/17",
    coastal_households_2017: "OM3 - 2017/18",
    coastal_households_2018: "OM3 - 2018/19",
    coastal_households_2019: "OM3 - 2019/20",
    coastal_households_2020: "OM3 - 2020/21",
    coastal_households_2021: "OM3 - 2021/22",
    coastal_households_2022: "OM3 - 2022/23",
    coastal_households_2023: "OM3 - 2023/24",
    coastal_households_2024: "OM3 - 2024/25",
    coastal_households_2025: "OM3 - 2025/26",
    coastal_households_2026: "OM3 - 2026/27",
    coastal_households_2027: "OM3 - 2027/28 on",
    coastal_households_protected_previous_years: "OM3b - PREVIOUS YEARS",
    coastal_households_protected_2015: "OM3b - 2015/16",
    coastal_households_protected_2016: "OM3b - 2016/17",
    coastal_households_protected_2017: "OM3b - 2017/18",
    coastal_households_protected_2018: "OM3b - 2018/19",
    coastal_households_protected_2019: "OM3b - 2019/20",
    coastal_households_protected_2020: "OM3b - 2020/21",
    coastal_households_protected_2021: "OM3b - 2021/22",
    coastal_households_protected_2022: "OM3b - 2022/23",
    coastal_households_protected_2023: "OM3b - 2023/24",
    coastal_households_protected_2024: "OM3b - 2024/25",
    coastal_households_protected_2025: "OM3b - 2025/26",
    coastal_households_protected_2026: "OM3b - 2026/27",
    coastal_households_protected_2027: "OM3b - 2027/28 on",
    coastal_most_deprived_previous_years: "OM3c - PREVIOUS YEARS",
    coastal_most_deprived_2015: "OM3c - 2015/16",
    coastal_most_deprived_2016: "OM3c - 2016/17",
    coastal_most_deprived_2017: "OM3c - 2017/18",
    coastal_most_deprived_2018: "OM3c - 2018/19",
    coastal_most_deprived_2019: "OM3c - 2019/20",
    coastal_most_deprived_2020: "OM3c - 2020/21",
    coastal_most_deprived_2021: "OM3c - 2021/22",
    coastal_most_deprived_2022: "OM3c - 2022/23",
    coastal_most_deprived_2023: "OM3c - 2023/24",
    coastal_most_deprived_2024: "OM3c - 2024/25",
    coastal_most_deprived_2025: "OM3c - 2025/26",
    coastal_most_deprived_2026: "OM3c - 2026/27",
    coastal_most_deprived_2027: "OM3c - 2027/28 on",
    gia_future_total: "GiA 17/18 - 20/21 total",
    total_future_total: "TPE 17/18 - 20/21 total",
    future_contributions_total: "Contributions 17/18 - 20/21 total",
    future_households_total: "OM2+3 17/18 - 20/21 total",
    earliest_start: "Earliest date funding profile could be accelerated to (first year of TPE spend)",
    start_outline_business_case: "Gateway 1 (Business Case/Justification)",
    award_contract: "Gateway 3 (Contract Award/Investment Decision)",
    start_construction: "Start of construction",
    ready_for_service: "Gateway 4 (Readiness for Service)",
    flood_households_previous_years: "OM2 - PREVIOUS YEARS",
    flood_households_2015: "OM2 - 2015/16",
    flood_households_2016: "OM2 - 2016/17",
    flood_households_2017: "OM2 - 2017/18",
    flood_households_2018: "OM2 - 2018/19",
    flood_households_2019: "OM2 - 2019/20",
    flood_households_2020: "OM2 - 2020/21",
    flood_households_2021: "OM2 - 2021/22",
    flood_households_2022: "OM2 - 2022/23",
    flood_households_2023: "OM2 - 2023/24",
    flood_households_2024: "OM2 - 2024/25",
    flood_households_2025: "OM2 - 2025/26",
    flood_households_2026: "OM2 - 2026/27",
    flood_households_2027: "OM2 - 2027/28 on",
    flood_households_moved_previous_years: "OM2b - PREVIOUS YEARS",
    flood_households_moved_2015: "OM2b - 2015/16",
    flood_households_moved_2016: "OM2b - 2016/17",
    flood_households_moved_2017: "OM2b - 2017/18",
    flood_households_moved_2018: "OM2b - 2018/19",
    flood_households_moved_2019: "OM2b - 2019/20",
    flood_households_moved_2020: "OM2b - 2020/21",
    flood_households_moved_2021: "OM2b - 2021/22",
    flood_households_moved_2022: "OM2b - 2022/23",
    flood_households_moved_2023: "OM2b - 2023/24",
    flood_households_moved_2024: "OM2b - 2024/25",
    flood_households_moved_2025: "OM2b - 2025/26",
    flood_households_moved_2026: "OM2b - 2026/27",
    flood_households_moved_2027: "OM2b - 2027/28 on",
    flood_most_deprived_previous_years: "OM2c - PREVIOUS YEARS",
    flood_most_deprived_2015: "OM2c - 2015/16",
    flood_most_deprived_2016: "OM2c - 2016/17",
    flood_most_deprived_2017: "OM2c - 2017/18",
    flood_most_deprived_2018: "OM2c - 2018/19",
    flood_most_deprived_2019: "OM2c - 2019/20",
    flood_most_deprived_2020: "OM2c - 2020/21",
    flood_most_deprived_2021: "OM2c - 2021/22",
    flood_most_deprived_2022: "OM2c - 2022/23",
    flood_most_deprived_2023: "OM2c - 2023/24",
    flood_most_deprived_2024: "OM2c - 2024/25",
    flood_most_deprived_2025: "OM2c - 2025/26",
    flood_most_deprived_2026: "OM2c - 2026/27",
    flood_most_deprived_2027: "OM2c - 2027/28 on",
    hectares_of_net_water_dependent_habitat_created: "OM4a - PROJECT TOTAL",
    hectares_of_net_water_intertidal_habitat_created: "OM4b - PROJECT TOTAL",
    kilometres_of_protected_river_improved: "OM4c - PROJECT TOTAL",
    hectares_of_net_water_dependent_habitat_created_previous_years: "OM4a - PREVIOUS YEARS",
    hectares_of_net_water_dependent_habitat_created_2015: "OM4a - 2015/16",
    hectares_of_net_water_dependent_habitat_created_2016: "OM4a - 2016/17",
    hectares_of_net_water_dependent_habitat_created_2017: "OM4a - 2017/18",
    hectares_of_net_water_dependent_habitat_created_2018: "OM4a - 2018/19",
    hectares_of_net_water_dependent_habitat_created_2019: "OM4a - 2019/20",
    hectares_of_net_water_dependent_habitat_created_2020: "OM4a - 2020/21",
    hectares_of_net_water_dependent_habitat_created_2021: "OM4a - 2021/22",
    hectares_of_net_water_dependent_habitat_created_2022: "OM4a - 2022/23",
    hectares_of_net_water_dependent_habitat_created_2023: "OM4a - 2023/24",
    hectares_of_net_water_dependent_habitat_created_2024: "OM4a - 2024/25",
    hectares_of_net_water_dependent_habitat_created_2025: "OM4a - 2025/26",
    hectares_of_net_water_dependent_habitat_created_2026: "OM4a - 2026/27",
    hectares_of_net_water_dependent_habitat_created_2027: "OM4a - 2027/28 on",
    hectares_of_net_water_intertidal_habitat_created_previous_years: "OM4b - PREVIOUS YEARS",
    hectares_of_net_water_intertidal_habitat_created_2015: "OM4b - 2015/16",
    hectares_of_net_water_intertidal_habitat_created_2016: "OM4b - 2016/17",
    hectares_of_net_water_intertidal_habitat_created_2017: "OM4b - 2017/18",
    hectares_of_net_water_intertidal_habitat_created_2018: "OM4b - 2018/19",
    hectares_of_net_water_intertidal_habitat_created_2019: "OM4b - 2019/20",
    hectares_of_net_water_intertidal_habitat_created_2020: "OM4b - 2020/21",
    hectares_of_net_water_intertidal_habitat_created_2021: "OM4b - 2021/22",
    hectares_of_net_water_intertidal_habitat_created_2022: "OM4b - 2022/23",
    hectares_of_net_water_intertidal_habitat_created_2023: "OM4b - 2023/24",
    hectares_of_net_water_intertidal_habitat_created_2024: "OM4b - 2024/25",
    hectares_of_net_water_intertidal_habitat_created_2025: "OM4b - 2025/26",
    hectares_of_net_water_intertidal_habitat_created_2026: "OM4b - 2026/27",
    hectares_of_net_water_intertidal_habitat_created_2027: "OM4b - 2027/28 on",
    kilometres_of_protected_river_improved_previous_years: "OM4c - PREVIOUS YEARS",
    kilometres_of_protected_river_improved_2015: "OM4c - 2015/16",
    kilometres_of_protected_river_improved_2016: "OM4c - 2016/17",
    kilometres_of_protected_river_improved_2017: "OM4c - 2017/18",
    kilometres_of_protected_river_improved_2018: "OM4c - 2018/19",
    kilometres_of_protected_river_improved_2019: "OM4c - 2019/20",
    kilometres_of_protected_river_improved_2020: "OM4c - 2020/21",
    kilometres_of_protected_river_improved_2021: "OM4c - 2021/22",
    kilometres_of_protected_river_improved_2022: "OM4c - 2022/23",
    kilometres_of_protected_river_improved_2023: "OM4c - 2023/24",
    kilometres_of_protected_river_improved_2024: "OM4c - 2024/25",
    kilometres_of_protected_river_improved_2025: "OM4c - 2025/26",
    kilometres_of_protected_river_improved_2026: "OM4c - 2026/27",
    kilometres_of_protected_river_improved_2027: "OM4c - 2027/28 on",
    pv_whole_life_costs: "PV Whole Life Costs £",
    pv_whole_life_benefits: "PV Whole Life Benefits £",
    pv_whole_life_benefit_cost_ratio: "PV Whole Life Benefits/ PV Whole Life Costs (Benefit / Cost Ratio)",
    duration_of_benefits: "Duration of Benefits Yrs",
    raw_partnership_funding_score: "Raw Partnership Funding Score %",
    adjusted_partnership_funding_score: "Adjusted Partnership Funding Score (PF) %",
    strategic_approach: "Is evidence available that a Strategic Approach has been taken,\
      and that double counting of Benefits has been avoided ? Y or N",
    project_status: "Project Status",
    finance_category: "Finance category of asset/works (CWEiYes/tangible/intangible)",
    additional_function: "Additional function (we assume these projects have a primary FCRM function)",
    packages: "Packages",
    ldw_cpw_idb_number: "LDW/ CPW / IDB Number",
    lrma_project_reference: "LRMA Project Reference or EA 1B1S no.",
    parliamentary_constituencies_benefit_area: "Parliamentary Constituencies - Benefit Area",
    agreed_strategy: "Agreed strategy",
    environmental_considerations: "Environmental Considerations including Designated Sites",
    new_builds: "New Builds %",
    scheme_comments: "Scheme comments",
    additional_potential: "Additional potential for environmental outcomes against Defra performance specification?",
    additional_funding_required_for_additional_benefits: "Would additional funding be required to \
    deliver the additional benefits?",
    public_contributor_names: "Who are the public sector contributors?",
    private_contributor_names: "Who are the private sector contributors?",
    other_ea_contributor_names: "What are the contributions from other Environment Agency sources?",
    project_executive: "Project Executive (for PPMT)",
    project_manager: "Project Manager (for PPMT)",
    project_record_owner: "Project Record Owner",
    county: "County"
  }.freeze
end
