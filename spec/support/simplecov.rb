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
  add_filter "lib/pafs_core/data_migration/move_growth_funding_to_other_additional_gia.rb"
  add_filter "lib/pafs_core/date_utils.rb"
  add_filter "lib/pafs_core/funding_sources.rb"
  add_filter "lib/pafs_core/mapper/fcerm.rb"
  add_filter "lib/pafs_core/mapper/funding_sources.rb"
  add_filter "lib/pafs_core/spreadsheet_column_order.rb"
  add_filter "lib/pafs_core/spreadsheet_column_headers.rb"
  add_filter "lib/pafs_core/mapper/funding_calculator_maps/v9.rb"
  add_filter "lib/pafs_core/files.rb"
  add_filter "lib/pafs_core/mapping_transforms.rb"
  add_filter "lib/pafs_core/spreadsheet_custom_styles.rb"
  add_filter "lib/pafs_core/spreadsheet_custom_styles/spreadsheet_custom_styles.rb"
  add_filter "lib/pafs_core/fcerm1.rb"
  add_filter "lib/pafs_core/mapper/partnership_funding_calculator.rb"
  add_filter "lib/pafs_core/sql_columns_for_spreadsheet.rb"
  add_filter "lib/pafs_core/mapper/funding_calculator_maps/v8.rb"
  add_filter "lib/pafs_core/standard_of_protection.rb"
  add_filter "lib/pafs_core.rb"
  add_filter "lib/pafs_core/pol/azure_oauth.rb"
  add_filter "lib/pafs_core/rfcc_codes.rb"
  add_filter "lib/pafs_core/pol/submission.rb"
  add_filter "lib/pafs_core/pol/archive.rb"
  add_filter "lib/pafs_core/pol/azure_vault_client.rb"
  add_filter "lib/pafs_core/outcomes.rb"
  add_filter "lib/pafs_core/configuration.rb"
  add_filter "lib/pafs_core/data_migration/export_to_pol.rb"
  add_filter "lib/pafs_core/data_migration/generate_funding_contributor_fcerm.rb"
  add_filter "lib/pafs_core/data_migration/update_areas.rb"
  add_filter "lib/pafs_core/natural_flood_risk_measures.rb"
  add_filter "lib/pafs_core/environmental_outcomes.rb"
  add_filter "lib/pafs_core/data_migration/move_funding_sources.rb"
  add_filter "lib/pafs_core/risks.rb"
  add_filter "lib/pafs_core/urgency.rb"
  add_filter "lib/pafs_core/file_types.rb"
  add_filter "app/assets/javascripts/pafs_core/other_flood_measures.js"
  add_filter "app/helpers/pafs_core/application_helper.rb"
  add_filter "app/decorators/pafs_core/imported_project_decorator.rb"
  add_filter "app/services/pafs_core/program_upload_service.rb"
  add_filter "app/services/pafs_core/download/area.rb"
  add_filter "app/controllers/pafs_core/confirmation_controller.rb"
  add_filter "app/services/pafs_core/asite_service.rb"
  add_filter "app/services/pafs_core/spreadsheet/contributors/contributor.rb"
  add_filter "app/steps/pafs_core/funding_contributor_values_step.rb"
  add_filter "app/services/pafs_core/spreadsheet/contributors/import_all.rb"

  add_group "Forms", "app/forms"
  add_group "Presenters", "app/presenters"
  add_group "Services", "app/services"
  add_group "Validators", "app/validators"
end
