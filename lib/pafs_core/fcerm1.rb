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
      { column: "K",  field_name: :moderation_code },
      { column: "L",  field_name: :consented },
      { column: "M",  field_name: :grid_reference },
      { column: "N",  field_name: :county, import: false },
      { column: "O",  field_name: :parliamentary_constituency, import: false },
      { column: "P",  field_name: :approach },

      { column: "Q",
        field_name: :flood_protection_before,
        if: ->(p) { p.project_protects_households? } },

      { column: "R",
        field_name: :flood_protection_after,
        if: ->(p) { p.project_protects_households? } },

      { column: "S",
        field_name: :coastal_protection_before,
        if: ->(p) { p.project_protects_households? } },

      { column: "T",
        field_name: :coastal_protection_after,
        if: ->(p) { p.project_protects_households? } },

      { column: "U", field_name: :strategic_approach, import: false },
      { column: "V", field_name: :raw_partnership_funding_score, import: false },
      { column: "W", field_name: :adjusted_partnership_funding_score, import: false },
      { column: "X", field_name: :pv_whole_life_costs, import: false },
      { column: "Y", field_name: :pv_whole_life_benefits, import: false },
      { column: "Z", field_name: :benefit_cost_ratio, import: false },
      { column: "AA", field_name: :duration_of_benefits, import: false },

      { column: "AB", field_name: :public_contributors },
      { column: "AC", field_name: :private_contributors },
      { column: "AD", field_name: :other_ea_contributors },

      { column: "AE", field_name: :earliest_start_date },
      { column: "AF", field_name: :earliest_start_date_with_gia_available },

      { column: "AG", field_name: :start_business_case_date },
      { column: "AH", field_name: :complete_business_case_date },

      { column: "AI", field_name: :award_contract_date },
      { column: "AJ", field_name: :start_construction_date },
      { column: "AK", field_name: :ready_for_service_date },

      # Project totals AL - BJ (formula)
      { column: "AL", field_name: :project_totals, export: false, import: false },

      # Total Project expenditure BK - BT (formula)
      { column: "BK", field_name: :project_totals, export: false, import: false },

      # GiA columns BU - CD
      { column: "BU", field_name: :fcerm_gia, date_range: true },

      # Local levy columns CE - CN
      { column: "CE", field_name: :local_levy, date_range: true },

      # Internal drainage board columns CO - CX
      { column: "CO", field_name: :internal_drainage_boards, date_range: true },

      # Public contribution columns CY - DH
      { column: "CY", field_name: :public_contributions, date_range: true },

      # Private contribution columns DI - DR
      { column: "DI", field_name: :private_contributions, date_range: true },

      # Other EA contribution columns DS - EB
      { column: "DS", field_name: :other_ea_contributions, date_range: true },

      # Not yet identified contribution columns EC - EL
      { column: "EC", field_name: :not_yet_identified, date_range: true },

      # Households affected by flooding rOM2A EM - EV
      { column: "EM",
        field_name: :households_at_reduced_risk,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2A.b EW - FF
      { column: "EW",
        field_name: :moved_from_very_significant_and_significant_to_moderate_or_low,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2A.c FG - FP
      { column: "FG",
        field_name: :households_protected_from_loss_in_20_percent_most_deprived,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2A.PLP FQ - FZ
      { column: "FQ",
        field_name: :households_protected_through_plp_measures,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2A.NRP GA - GJ
      { column: "GA",
        field_name: :non_residential_properties,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2B GK - GT
      { column: "GK",
        field_name: :households_at_reduced_risk_2040,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2B.b GU - HD
      { column: "GU",
        field_name: :moved_from_very_significant_and_significant_to_moderate_or_low_2040,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2B.c HE - HN
      { column: "HE",
        field_name: :households_protected_from_loss_in_20_percent_most_deprived_2040,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM2B.NRP HO - HX
      { column: "HO",
        field_name: :non_residential_properties_2040,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Coastal erosion protection outcomes rOM3 HY - IH
      { column: "HY",
        field_name: :coastal_households_at_reduced_risk,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Coastal erosion protection outcomes rOM3.b II - IR
      { column: "II",
        field_name: :coastal_households_protected_from_loss_in_next_20_years,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Coastal erosion protection outcomes rOM3.c IS - JB
      { column: "IS",
        field_name: :coastal_households_protected_from_loss_in_20_percent_most_deprived,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding rOM3B.NRP JC - JL
      { column: "JC",
        field_name: :coastal_non_residential_properties,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # From PF calculator OM4A-C JM-JO
      { column: "JM", field_name: :hectares_of_net_water_dependent_habitat_created, import: false },
      { column: "JN", field_name: :hectares_of_net_water_intertidal_habitat_created, import: false },
      { column: "JO", field_name: :kilometres_of_protected_river_improved, import: false },

      # Natural flood risk management measure
      { column: "JP", field_name: :natural_measures, export: false, import: false },
      { column: "JQ", field_name: :main_natural_measure, export: false, import: false },
      { column: "JR", field_name: :natural_measures_costs, export: false, import: false },

      # # spa/sac, sssi or none
      { column: "JS", field_name: :designated_site },

      # OM4D-H JT-JY
      { column: "JT", field_name: :improve_surface_or_groundwater_amount },
      { column: "JU", field_name: :remove_fish_or_eel_barrier },
      { column: "JV", field_name: :fish_or_eel_amount },
      { column: "JW", field_name: :improve_river_amount },
      { column: "JX", field_name: :improve_habitat_amount },
      { column: "JY", field_name: :create_habitat_amount },

      # Confidence Assessment
      { column: "JZ", field_name: :confidence_homes_better_protected },
      { column: "KA", field_name: :confidence_homes_by_gateway_four },
      { column: "KB", field_name: :confidence_secured_partnership_funding },

      # Project Status
      { column: "KC", field_name: :project_status },

      # Carbon
      { column: "KD", field_name: :carbon_cost_build },
      { column: "KE", field_name: :carbon_cost_operation },

      # Additional columns per RUBY-2394
      { column: "KF", field_name: :last_updated, import: false },
      { column: "KG", field_name: :pso_name, import: false }
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
