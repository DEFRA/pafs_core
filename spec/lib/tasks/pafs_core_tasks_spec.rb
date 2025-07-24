# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/ExpectOutput
RSpec.describe "PafsCore::DataMigration", type: :rake do

  include_context "rake"

  original_stdout = $stdout

  before do
    # suppress noisy outputs during unit test
    $stdout = StringIO.new

    create(:full_project)
  end

  after { $stdout = original_stdout }

  describe "pafs:bulk_export_to_pol" do
    it { expect { Rake::Task["pafs:bulk_export_to_pol"].invoke }.not_to raise_error }
  end

  describe "pafs:update_areas" do
    it { expect { Rake::Task["pafs:update_areas"].invoke }.not_to raise_error }
  end

  describe "pafs:update_project_areas" do
    it { expect { Rake::Task["pafs:update_project_areas"].invoke }.not_to raise_error }
  end

  describe "pafs:generate_funding_contributor_fcerm" do
    let(:user) { create(:user, :rma) }

    before { allow(ENV).to receive(:fetch).with("USER_ID").and_return(user.id) }

    it { expect { Rake::Task["pafs:generate_funding_contributor_fcerm"].invoke }.not_to raise_error }
  end

  describe "pafs:move_funding_sources" do
    it { expect { Rake::Task["pafs:move_funding_sources"].invoke }.not_to raise_error }
  end

  describe "pafs:update_submission_date" do
    before { allow(ENV).to receive(:fetch).with("SUBMISSION_DATE").and_return(Time.zone.today.to_s) }

    it { expect { Rake::Task["pafs:update_submission_date"].invoke }.not_to raise_error }
  end

  describe "pafs:remove_previous_years" do
    subject(:task) { Rake::Task["pafs:remove_previous_years"] }

    it "runs without error" do
      allow(PafsCore::DataMigration::RemovePreviousYears).to receive(:perform)

      expect { task.invoke }.not_to raise_error

      expect(PafsCore::DataMigration::RemovePreviousYears).to have_received(:perform)
    end
  end

  describe "pafs:carbon_impact" do
    subject(:task) { Rake::Task["pafs:carbon_impact"] }

    let(:project) { build(:full_project) }
    let(:presenter) { PafsCore::CarbonImpactPresenter.new(project: project) }

    it "runs without error" do
      allow(PafsCore::Project).to receive(:find_by).and_return(project)
      allow(PafsCore::CarbonImpactPresenter).to receive(:new).and_return(presenter)

      allow(presenter).to receive(:operational_carbon_baseline)
      allow(presenter).to receive(:operational_carbon_target)
      allow(presenter).to receive(:operational_cost_estimate)
      allow(presenter).to receive(:net_carbon_with_blanks_calculated)
      allow(presenter).to receive(:net_economic_benefit_estimate)

      expect { task.invoke(reference_number: project.reference_number) }.not_to raise_error
      aggregate_failures do
        expect(presenter).to have_received(:operational_carbon_baseline)
        expect(presenter).to have_received(:operational_carbon_target)
        expect(presenter).to have_received(:operational_cost_estimate)
        expect(presenter).to have_received(:net_carbon_with_blanks_calculated)
        expect(presenter).to have_received(:net_economic_benefit_estimate)
      end
    end
  end
end
# rubocop:enable RSpec/ExpectOutput
