# frozen_string_literal: true

require "simplecov"
require "simplecov_json_formatter"

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
]

# We start it with the rails param to ensure it includes coverage for all code
# started by the rails app, and not just the files touched by our unit tests.
# This gives us the most accurate assessment of our unit test coverage
# https://github.com/colszowka/simplecov#getting-started
SimpleCov.start("rails") do
  # We filter the spec folder, mainly to ensure that any dummy apps don't get
  # included in the coverage report. However our intent is that nothing in the
  # spec folder should be included
  add_filter "/spec/"
  # Our db folder contains migrations and seeding, functionality we are ok not
  # to have tests for
  add_filter "/db/"
  # The version file is simply just that, so we do not feel the need to ensure
  # we have a test for it
  add_filter "lib/pafs_core/version"

  # These are just missing test coverage for now, but we will get to them
  # @todo: remove this once we have tests for it
  add_filter "lib/pafs_core/spreadsheet_custom_styles/spreadsheet_custom_styles.rb"
  add_filter "lib/pafs_core/files.rb"
  add_filter "lib/pafs_core/data_migration/update_areas.rb"
  add_filter "lib/pafs_core/data_migration/generate_funding_contributor_fcerm.rb"
  add_filter "lib/pafs_core/data_migration/export_to_pol.rb"
  add_filter "lib/pafs_core/configuration.rb"
  add_filter "lib/pafs_core/data_migration/update_projects.rb"
  add_filter "lib/pafs_core/data_migration/move_growth_funding_to_other_additional_gia.rb"
  add_filter "lib/pafs_core/file_types.rb"
  add_filter "lib/pafs_core/data_migration/update_pol_submission_date.rb"
  add_filter "lib/pafs_core/urgency.rb"
  add_filter "lib/pafs_core/email.rb"
  add_filter "app/services/pafs_core/program_upload_service.rb"
  add_filter "app/services/pafs_core/download/area.rb"
  add_filter "app/services/pafs_core/asite_service.rb"
  add_filter "app/services/pafs_core/spreadsheet/contributors/contributor.rb"
  add_filter "app/services/pafs_core/spreadsheet/contributors/import_all.rb"
  add_filter "app/services/pafs_core/projects/confidence_update.rb"
  add_filter "app/services/pafs_core/spreadsheet/contributors/coerce/base.rb"
  add_filter "app/services/pafs_core/spreadsheet/contributors/coerce/financial_year.rb"
  add_filter "app/services/pafs_core/spreadsheet_service.rb"
  add_filter "app/services/pafs_core/download/meta.rb"
  add_filter "app/services/pafs_core/spreadsheet/contributors/coerce/contributor_type.rb"
  add_filter "app/services/pafs_core/spreadsheet/contributors/coerce/boolean.rb"
  add_filter "app/services/pafs_core/spreadsheet/contributors/export.rb"
  add_filter "app/services/pafs_core/development_file_storage_service.rb"
  add_filter "app/services/pafs_core/area_download_service.rb"
  add_filter "app/services/pafs_core/download/all.rb"
  add_filter "app/services/pafs_core/download/base.rb"
  add_filter "app/jobs/pafs_core/account_request_cleanup_job.rb"
  add_filter "app/jobs/pafs_core/asite_submission_job.rb"
  add_filter "app/jobs/pafs_core/import_program_refresh_job.rb"
  add_filter "app/jobs/pafs_core/pol/archive_job.rb"
  add_filter "app/jobs/pafs_core/pol/submission_job.rb"
  add_filter "app/mailers/pafs_core/apt_notification_mailer.rb"
  add_filter "app/controllers/pafs_core/archives_controller.rb"
  add_filter "app/controllers/pafs_core/areas_controller.rb"
  add_filter "app/controllers/pafs_core/confirmation_controller.rb"
  add_filter "app/controllers/pafs_core/errors_controller.rb"
  add_filter "app/controllers/pafs_core/pages_controller.rb"
  add_filter "app/controllers/pafs_core/projects_controller.rb"
  add_filter "app/helpers/pafs_core/email_helper.rb"
  add_filter "app/helpers/pafs_core/application_helper.rb"
  add_filter "app/helpers/pafs_core/projects_helper.rb"
  add_filter "app/models/pafs_core/asite_file.rb"
  add_filter "app/models/pafs_core/asite_submission.rb"
  add_filter "app/models/pafs_core/state.rb"
  add_filter "app/presenters/pafs_core/projects_download_presenter.rb"
  add_filter "app/presenters/pafs_core/project_summary_presenter.rb"
  add_filter "app/presenters/pafs_core/validation_presenter.rb"
  add_filter "app/decorators/pafs_core/imported_project_decorator.rb"
  add_filter "app/steps/pafs_core/funding_contributor_values_step.rb"
  add_filter "app/steps/pafs_core/carbon_cost_operation_step.rb"
  add_filter "app/steps/pafs_core/funding_contributor_values_step.rb"
  add_filter "app/steps/pafs_core/grassland_habitat_created_or_enhanced_step.rb"
  add_filter "app/steps/pafs_core/hectares_of_intertidal_habitat_created_or_enhanced_step.rb"
  add_filter "app/steps/pafs_core/other_ea_contributor_values_step.rb"
  add_filter "app/steps/pafs_core/private_contributor_values_step.rb"
  add_filter "app/steps/pafs_core/public_contributor_values_step.rb"
  add_filter "app/steps/pafs_core/map_step.rb"

  add_group "Forms", "app/forms"
  add_group "Presenters", "app/presenters"
  add_group "Services", "app/services"
  add_group "Validators", "app/validators"
end
