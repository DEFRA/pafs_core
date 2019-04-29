# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

namespace :pafs do
  task remove_duplicate_states: :environment do
    PafsCore::DataMigration::RemoveDuplicateStates.perform_all
  end
end
