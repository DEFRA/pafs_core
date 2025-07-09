# frozen_string_literal: true

module PafsCore
  module DataMigration
    class RemoveOldPfcVersions
      include PafsCore::Files
      include PafsCore::FundingCalculatorVersion

      def self.perform
        new.perform
      end

      def perform
        projects_with_pfc.find_each do |project|
          if old_pfc_version?(project)
            Rails.logger.info "Removing old PFC version for project #{project.reference_number}" unless Rails.env.test?
            # this removed the file and updates project's pfc attributes
            delete_funding_calculator_for(project)
          end
        end
      end

      private

      def projects_with_pfc
        PafsCore::Project
          .joins(:state)
          .where(pafs_core_states: { state: %w[draft archived] })
          .where.not(funding_calculator_file_name: nil)
      end

      def old_pfc_version?(project)
        return false unless project.funding_calculator_file_name

        calculator_version.present? && !calculator_version_accepted?
      end
    end
  end
end
