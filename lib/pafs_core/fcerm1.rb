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

      # Project totals AL - BC (formula)
      { column: "AL", field_name: :project_totals, export: false, import: false },

      # Total Project expenditure BD - BM (formula)
      { column: "BD", field_name: :project_totals, export: false, import: false },

      # GiA columns BN - BW
      { column: "BN", field_name: :fcerm_gia, date_range: true },

      # Local levy columns BX - CG
      { column: "BX", field_name: :local_levy, date_range: true },

      # Internal drainage board columns CH - CQ
      { column: "CH", field_name: :internal_drainage_boards, date_range: true },

      # Public contribution columns CR - DA
      { column: "CR", field_name: :public_contributions, date_range: true },

      # Private contribution columns DB - DK
      { column: "DB", field_name: :private_contributions, date_range: true },

      # Other EA contribution columns DL - DU
      { column: "DL", field_name: :other_ea_contributions, date_range: true },

      # Not yet identified contribution columns DV - EE
      { column: "DV", field_name: :not_yet_identified, date_range: true },

      # Households affected by flooding OM2 EF - EO
      { column: "EF",
        field_name: :households_at_reduced_risk,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding OM2b EP - EY
      { column: "EP",
        field_name: :moved_from_very_significant_and_significant_to_moderate_or_low,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding OM2c EZ - FI
      { column: "EZ",
        field_name: :households_protected_from_loss_in_20_percent_most_deprived,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Coastal erosion protection outcomes OM3 FJ - FS
      { column: "FJ",
        field_name: :coastal_households_at_reduced_risk,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Coastal erosion protection outcomes OM3b FT - GC
      { column: "FT",
        field_name: :coastal_households_protected_from_loss_in_next_20_years,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Coastal erosion protection outcomes OM3c GD - GM
      { column: "GD",
        field_name: :coastal_households_protected_from_loss_in_20_percent_most_deprived,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # From PF calculator OM4A-C GM-GO
      { column: "GN", field_name: :hectares_of_net_water_dependent_habitat_created, import: false },
      { column: "GO", field_name: :hectares_of_net_water_intertidal_habitat_created, import: false },
      { column: "GP", field_name: :kilometres_of_protected_river_improved, import: false },

      # Natural flood risk management measure
      { column: "GQ", field_name: :natural_measures, export: false, import: false },
      { column: "GR", field_name: :main_natural_measure, export: false, import: false },
      { column: "GS", field_name: :natural_measures_costs, export: false, import: false },

      # # spa/sac, sssi or none
      { column: "GT", field_name: :designated_site },

      # OM4D-H
      { column: "GU", field_name: :improve_surface_or_groundwater_amount },
      { column: "GV", field_name: :remove_fish_or_eel_barrier },
      { column: "GW", field_name: :fish_or_eel_amount },
      { column: "GX", field_name: :improve_river_amount },
      { column: "GY", field_name: :improve_habitat_amount },
      { column: "GZ", field_name: :create_habitat_amount },

      # Confidence Assessment
      { column: "HI", field_name: :confidence_homes_better_protected },
      { column: "HJ", field_name: :confidence_homes_by_gateway_four },
      { column: "HK", field_name: :confidence_secured_partnership_funding },

      # Project Status
      { column: "HL", field_name: :project_status },

      # Carbon
      { column: "HM", field_name: :carbon_cost_build },
      { column: "HN", field_name: :carbon_cost_operation },

      # Additional columns per RUBY-2394
      { column: "HO", field_name: :last_updated, import: false },
      { column: "HP", field_name: :pso_name, import: false }
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
