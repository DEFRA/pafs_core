# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :pafs do
  task bulk_export_to_pol: :environment do
    PafsCore::DataMigration::ExportToPol.perform
  end

  task remove_duplicate_states: :environment do
    PafsCore::DataMigration::RemoveDuplicateStates.perform_all
  end

  task update_areas: :environment do
    PafsCore::DataMigration::UpdateAreas.perform(
      Rails.root.join("lib/fixtures/area_migration.csv")
    )
  end

  task update_project_areas: :environment do
    PafsCore::DataMigration::UpdateProjects.perform(
      Rails.root.join("lib/fixtures/project_area_migration.csv")
    )
  end

  task update_authorities: :environment do
    PafsCore::DataMigration::UpdateAuthorities.up
  end

  task generate_funding_contributor_fcerm: :environment do
    user = PafsCore::User.find(ENV.fetch("USER_ID"))
    PafsCore::DataMigration::GenerateFundingContributorFcerm.perform(user)
  end

  task move_funding_sources: :environment do
    PafsCore::DataMigration::MoveFundingSources.perform_all
  end

  task update_submission_date: :environment do
    PafsCore::DataMigration::UpdatePolSubmissionDate.perform
  end

  desc "Remove data for financial years before the current financial year"
  task :remove_previous_years, [:max_projects] => :environment do |_t, args|
    project_limit = if args[:max_projects].present?
                      args[:max_projects].to_i
                    else
                      ENV.fetch("REMOVE_PREVIOUS_YEARS_MAX_PROJECTS", 100).to_i
                    end
    PafsCore::DataMigration::RemovePreviousYears.perform(project_limit)
  end
end
# rubocop:enable Metrics/BlockLength
