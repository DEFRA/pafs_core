# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

namespace :pafs do
  task bulk_export_to_pol: :environment do
    PafsCore::DataMigration::ExportToPol.perform
  end

  task remove_duplicate_states: :environment do
    PafsCore::DataMigration::RemoveDuplicateStates.perform_all
  end

  task update_areas: :environment do
    PafsCore::DataMigration::UpdateAreas.perform(
      File.join(Rails.root, "lib", "fixtures", "area_migration.csv")
    )
  end

  task update_project_areas: :environment do
    PafsCore::DataMigration::UpdateProjects.perform(
      File.join(Rails.root, "lib", "fixtures", "project_area_migration.csv")
    )
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
end
