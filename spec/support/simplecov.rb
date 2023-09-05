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
  add_filter "app/helpers/pafs_core/application_helper.rb"
  add_filter "app/decorators/pafs_core/imported_project_decorator.rb"
  add_filter "lib/pafs_core/mapper/fcerm.rb"
  add_filter "app/helpers/pafs_core/application_helper.rb"
  add_filter "app/decorators/pafs_core/imported_project_decorator.rb"
  add_filter "lib/pafs_core/data_migration/move_growth_funding_to_other_additional_gia.rb"
  add_filter "lib/pafs_core/date_utils.rb"
  add_filter "lib/pafs_core/funding_sources.rb"
  add_filter "app/assets/javascripts/pafs_core/other_flood_measures.js"
  add_filter "lib/pafs_core/mapper/funding_sources.rb"

  add_group "Forms", "app/forms"
  add_group "Presenters", "app/presenters"
  add_group "Services", "app/services"
  add_group "Validators", "app/validators"
end
