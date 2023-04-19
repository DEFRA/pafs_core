# frozen_string_literal: true

module PafsCore
  module Mapper
    class Fcerm1
      attr_accessor :project

      def initialize(project:)
        self.project = project
      end

      delegate :name, :coastal_group, :moderation_code, :package_reference, :strategic_approach,
               :duration_of_benefits, :households_at_reduced_risk,
               :moved_from_very_significant_and_significant_to_moderate_or_low,
               :households_protected_from_loss_in_20_percent_most_deprived,
               :households_protected_through_plp_measures,
               :non_residential_properties, :coastal_households_at_reduced_risk,
               :coastal_households_protected_from_loss_in_20_percent_most_deprived,
               to: :project

      def type
        project.project_type
      end

      def national_project_number
        project.reference_number
      end

      def pafs_ons_region
        project.region
      end

      def pafs_region_and_coastal_commitee
        project.rfcc
      end

      def pafs_ea_area
        project.ea_area
      end

      def lrma_name
        project.rma_name
      end

      def email
        project.creator&.email
      end

      def lrma_type
        project.rma_type
      end

      def risk_source
        project.main_risk
      end

      def constituency
        project.parliamentary_constituency
      end

      def pafs_county
        project.county
      end

      def earliest_start_date
        project.earliest_start_date
      end

      def earliest_start_date_with_gia_available
        project.earliest_start_date_with_gia_available
      end

      def aspirational_gateway_1
        project.start_business_case_date
      end

      def aspirational_gateway_2
        project.complete_business_case_date
      end

      def aspirational_gateway_3
        project.award_contract_date
      end

      def aspirational_start_of_construction
        project.start_construction_date
      end

      def aspirational_gateway_4
        project.ready_for_service_date
      end

      def problem_and_proposed_solution
        project.approach
      end

      def flooding_standard_of_protection_before
        project.flood_protection_before
      end

      def flooding_standard_of_protection_after
        project.flood_protection_after
      end

      def coastal_erosion_standard_of_protection_before
        project.coastal_protection_before
      end

      def coastal_erosion_standard_of_protection_after
        project.coastal_protection_after
      end

      def attributes
        {
          name: name,
          type: type,
          national_project_number: national_project_number,
          pafs_ons_region: pafs_ons_region,
          pafs_region_and_coastal_commitee: pafs_region_and_coastal_commitee,
          pafs_ea_area: pafs_ea_area,
          lrma_name: lrma_name,
          lrma_type: lrma_type,
          email: email,
          coastal_group: coastal_group,
          risk_source: risk_source,
          moderation_code: moderation_code,
          constituency: constituency,
          pafs_county: pafs_county,
          earliest_start_date: earliest_start_date,
          earliest_start_date_with_gia_available: earliest_start_date_with_gia_available,
          aspirational_gateway_1: aspirational_gateway_1,
          aspirational_gateway_2: aspirational_gateway_2,
          aspirational_gateway_3: aspirational_gateway_3,
          aspirational_start_of_construction: aspirational_start_of_construction,
          aspirational_gateway_4: aspirational_gateway_4,
          problem_and_proposed_solution: problem_and_proposed_solution,
          flooding_standard_of_protection_before: flooding_standard_of_protection_before,
          flooding_standard_of_protection_after: flooding_standard_of_protection_after,
          coastal_erosion_standard_of_protection_before: coastal_erosion_standard_of_protection_before,
          coastal_erosion_standard_of_protection_after: coastal_erosion_standard_of_protection_after,
          strategic_approach: strategic_approach,
          duration_of_benefits: duration_of_benefits
        }
      end
    end
  end
end
