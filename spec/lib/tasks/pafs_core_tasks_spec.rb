# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/ExpectOutput
RSpec.describe "pafs:remove_previous_years", type: :rake do
  subject(:task) { Rake::Task["pafs:remove_previous_years"] }

  include_context "rake"

  original_stdout = $stdout

  before do
    # suppress noisy outputs during unit test
    $stdout = StringIO.new

    create(:full_project)
  end

  after do
    $stdout = original_stdout
  end

  it "runs without error" do
    allow(PafsCore::DataMigration::RemovePreviousYears).to receive(:perform_all)

    expect { task.invoke }.not_to raise_error

    expect(PafsCore::DataMigration::RemovePreviousYears).to have_received(:perform_all)
  end
end
# rubocop:enable RSpec/ExpectOutput
