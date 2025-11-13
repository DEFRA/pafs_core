# frozen_string_literal: true

module PafsCore
  module Fcerm1
    FIRST_DATA_ROW = 6

    FCERM1_COLUMN_MAP = [
      { column: "A",  field_name: :reference_number },
      { column: "B",  field_name: :name },
      { column: "C",  field_name: :region, import: false },
      { column: "D",  field_name: :rfcc, import: false },
      { column: "E",  field_name: :ea_area, import: false },
      { column: "F",  field_name: :rma_name },
      { column: "G",  field_name: :rma_type, import: false },
      { column: "H",  field_name: :coastal_group, import: false },
      { column: "I",  field_name: :project_type },
      { column: "J",  field_name: :main_risk },
      { column: "K",  field_name: :secondary_risk_sources },
      { column: "L",  field_name: :moderation_code },
      { column: "M",  field_name: :consented },
      { column: "N",  field_name: :grid_reference },
      { column: "O",  field_name: :county, import: false },
      { column: "P",  field_name: :parliamentary_constituency, import: false },
      { column: "Q",  field_name: :approach },

      { column: "R",
        field_name: :flood_protection_before,
        if: ->(p) { p.project_protects_households? } },

      { column: "S",
        field_name: :flood_protection_after,
        if: ->(p) { p.project_protects_households? } },

      { column: "T",
        field_name: :coastal_protection_before,
        if: ->(p) { p.project_protects_households? } },

      { column: "U",
        field_name: :coastal_protection_after,
        if: ->(p) { p.project_protects_households? } },

      { column: "V", field_name: :strategic_approach, import: false },
      { column: "W", field_name: :raw_partnership_funding_score, import: false },
      { column: "X", field_name: :adjusted_partnership_funding_score, import: false },
      { column: "Y", field_name: :pv_whole_life_costs, import: false },
      { column: "Z", field_name: :pv_whole_life_benefits, import: false },
      { column: "AA", field_name: :benefit_cost_ratio, import: false },
      { column: "AB", field_name: :duration_of_benefits, import: false },

      { column: "AC", field_name: :public_contributors },
      { column: "AD", field_name: :private_contributors },
      { column: "AE", field_name: :other_ea_contributors },

      { column: "AF", field_name: :earliest_start_date },
      { column: "AG", field_name: :earliest_start_date_with_gia_available },

      { column: "AH", field_name: :start_business_case_date },
      { column: "AI", field_name: :complete_business_case_date },

      { column: "AJ", field_name: :award_contract_date },
      { column: "AK", field_name: :start_construction_date },
      { column: "AL", field_name: :ready_for_service_date },

      # Project totals AM - BQ (formula)
      { column: "AM", field_name: :project_totals, export: false, import: false },

      # Total Project expenditure BO - BX (formula)
      { column: "BO", field_name: :project_totals, export: false, import: false },

      # GiA columns BY - CH
      { column: "BY", field_name: :fcerm_gia, date_range: true },

      # Additional FCRM GiA (Asset replacement allowance) CI - CR
      { column: "CI", field_name: :asset_replacement_allowance, date_range: true },

      # Additional FCRM GiA (Environment statutory funding) CS - DB
      { column: "CS", field_name: :environment_statutory_funding, date_range: true },

      # Additional FCRM GiA (Frequently flooded communities) DC - DL
      { column: "DC", field_name: :frequently_flooded_communities, date_range: true },

      # Additional FCRM GiA (Other additional grant in aid) DM - DV
      { column: "DM", field_name: :other_additional_grant_in_aid, date_range: true },

      # Additional FCRM GiA (Other government department) DW - EF
      { column: "DW", field_name: :other_government_department, date_range: true },

      # Additional FCRM GiA (Recovery) EG - EP
      { column: "EG", field_name: :recovery, date_range: true },

      # Additional FCRM GiA (Summer economic fund) EQ - EZ
      { column: "EQ", field_name: :summer_economic_fund, date_range: true },

      # Local levy columns FA - FJ
      { column: "FA", field_name: :local_levy, date_range: true },

      # Internal drainage board columns FK - FT
      { column: "FK", field_name: :internal_drainage_boards, date_range: true },

      # Public contribution columns FU - GD
      { column: "FU", field_name: :public_contributions, date_range: true },

      # Private contribution columns GE - GN
      { column: "GE", field_name: :private_contributions, date_range: true },

      # Other EA contribution columns GO - GX
      { column: "GO", field_name: :other_ea_contributions, date_range: true },

      # Not yet identified contribution columns GY - HH
      { column: "GY", field_name: :not_yet_identified, date_range: true },

      # Households affected by flooding rOM2A HI - HR
      { column: "HI",
        field_name: :households_at_reduced_risk,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2A.b HS - IB
      { column: "HS",
        field_name: :moved_from_very_significant_and_significant_to_moderate_or_low,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2A.c IC - IL
      { column: "IC",
        field_name: :households_protected_from_loss_in_20_percent_most_deprived,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2A.PLP IM - IV
      { column: "IM",
        field_name: :households_protected_through_plp_measures,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2A.NRP IW - JF
      { column: "IW",
        field_name: :non_residential_properties,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2B JG - JP
      { column: "JG",
        field_name: :households_at_reduced_risk_2040,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2B.b JQ - JZ
      { column: "JQ",
        field_name: :moved_from_very_significant_and_significant_to_moderate_or_low_2040,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2B.c KA - KJ
      { column: "KA",
        field_name: :households_protected_from_loss_in_20_percent_most_deprived_2040,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2B.NRP KK - KT
      { column: "KK",
        field_name: :non_residential_properties_2040,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Coastal erosion protection outcomes rOM3 KU - LD
      { column: "KU",
        field_name: :coastal_households_at_reduced_risk,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Coastal erosion protection outcomes rOM3.b LE - LN
      { column: "LE",
        field_name: :coastal_households_protected_from_loss_in_next_20_years,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Coastal erosion protection outcomes rOM3.c LO - LX
      { column: "LO",
        field_name: :coastal_households_protected_from_loss_in_20_percent_most_deprived,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM3B.NRP LY - MH
      { column: "LY",
        field_name: :coastal_non_residential_properties,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Natural flood risk management measure
      { column: "MI", field_name: :hectares_of_intertidal_habitat_created_or_enhanced },
      { column: "MJ", field_name: :hectares_of_woodland_habitat_created_or_enhanced },
      { column: "MK", field_name: :hectares_of_wet_woodland_habitat_created_or_enhanced },
      { column: "ML", field_name: :hectares_of_wetland_or_wet_grassland_created_or_enhanced },
      { column: "MM", field_name: :hectares_of_grassland_habitat_created_or_enhanced },
      { column: "MN", field_name: :hectares_of_heathland_created_or_enhanced },
      { column: "MO", field_name: :hectares_of_pond_or_lake_habitat_created_or_enhanced },
      { column: "MP", field_name: :hectares_of_arable_land_lake_habitat_created_or_enhanced },
      { column: "MQ", field_name: :kilometres_of_watercourse_enhanced_or_created_comprehensive },
      { column: "MR", field_name: :kilometres_of_watercourse_enhanced_or_created_partial },
      { column: "MS", field_name: :kilometres_of_watercourse_enhanced_or_created_single },
      { column: "MT", field_name: :contains_natural_measures },
      { column: "MU", field_name: :main_natural_measure },
      { column: "MV", field_name: :natural_flood_risk_measures_cost },

      # Confidence Assessment
      { column: "MW", field_name: :confidence_homes_better_protected },
      { column: "MX", field_name: :confidence_homes_by_gateway_four },
      { column: "MY", field_name: :confidence_secured_partnership_funding },

      # Project Status
      { column: "MZ", field_name: :project_status },

      # Carbon impact
      { column: "NA", field_name: :carbon_cost_build },
      { column: "NB", field_name: :carbon_cost_operation },
      { column: "NC", field_name: :carbon_cost_sequestered },
      { column: "ND", field_name: :carbon_cost_avoided },
      { column: "NE", field_name: :carbon_savings_net_economic_benefit },
      { column: "NF", field_name: :carbon_operational_cost_forecast },

      # Additional columns per RUBY-2394
      { column: "NG", field_name: :last_updated, import: false },
      { column: "NH", field_name: :last_updated_by, import: false },
      { column: "NI", field_name: :pso_name, import: false }
    ].freeze

    A2Z = ("A".."Z").to_a.freeze

    # convert spreadsheet column "code" (eg. A, GF, ZZ) to column index
    def column_index(column_code)
      if column_code.length == 1
        A2Z.index(column_code)
      else
        n = A2Z.index(column_code[0])
        m = A2Z.index(column_code[1])
        26 + (n * 26) + m
      end
    end
  end
end
