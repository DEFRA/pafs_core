# frozen_string_literal: true

require "memory_profiler"
require "rails_helper"

RSpec.describe PafsCore::DataMigration::GenerateFundingContributorFcerm do
  let(:user) { create(:user, :pso) }

  before do
    create_list(:full_project, 10, :with_funding_values, public_contribution_names: %w[Matt Test])
  end

  describe "#perform" do
    xit "testing perf" do
      report = MemoryProfiler.report do
        described_class.perform(user)
        puts "complete" # rubocop:disable Rails/Output
      end

      report.pretty_print
    end
  end
end
