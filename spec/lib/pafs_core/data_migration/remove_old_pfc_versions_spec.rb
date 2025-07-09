# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::DataMigration::RemoveOldPfcVersions do
  describe "#perform" do
    let(:migration) { described_class.new }
    let(:project_with_v8_pfc) { create(:project, :draft, funding_calculator_file_name: "v8_calculator.xlsx") }
    let(:project_with_v9_pfc) { create(:project, :draft, funding_calculator_file_name: "v9_calculator.xlsx") }
    let(:project_without_pfc) { create(:project, :draft) }
    let(:archived_project_with_v8_pfc) { create(:project, :archived, funding_calculator_file_name: "v8_calculator.xlsx") }
    let(:submitted_project_with_v8_pfc) { create(:project, :submitted, funding_calculator_file_name: "v8_calculator.xlsx") }

    before do
      allow(migration).to receive(:delete_funding_calculator_for)
      allow(Rails.logger).to receive(:info)
    end

    context "when processing projects with different PFC versions" do
      before do
        allow(migration).to receive_messages(calculator_version: :v8, calculator_version_accepted?: false)
      end

      it "removes old PFC versions from draft projects" do
        project_with_v8_pfc
        allow(migration).to receive(:delete_funding_calculator_for).with(project_with_v8_pfc)

        migration.perform

        expect(migration).to have_received(:delete_funding_calculator_for).with(project_with_v8_pfc)
      end

      it "removes old PFC versions from archived projects" do
        archived_project_with_v8_pfc
        allow(migration).to receive(:delete_funding_calculator_for).with(archived_project_with_v8_pfc)

        migration.perform

        expect(migration).to have_received(:delete_funding_calculator_for).with(archived_project_with_v8_pfc)
      end

      it "logs removal message for each project" do
        project_with_v8_pfc
        allow(Rails.env).to receive(:test?).and_return(false)

        migration.perform

        expect(Rails.logger).to have_received(:info).with(/Removing old PFC version/)
      end
    end

    context "when projects have accepted PFC versions" do
      before do
        allow(migration).to receive_messages(calculator_version: :v9, calculator_version_accepted?: true)
      end

      it "does not remove v9 PFC files" do
        project_with_v9_pfc

        migration.perform

        expect(migration).not_to have_received(:delete_funding_calculator_for)
      end
    end

    context "when projects have no PFC files" do
      it "skips projects without PFC files" do
        project_without_pfc

        migration.perform

        expect(migration).not_to have_received(:delete_funding_calculator_for)
      end
    end

    context "when projects are in submitted state" do
      before do
        allow(migration).to receive_messages(calculator_version: :v8, calculator_version_accepted?: false)
      end

      it "does not process submitted projects" do
        submitted_project_with_v8_pfc

        migration.perform

        expect(migration).not_to have_received(:delete_funding_calculator_for)
      end
    end

    context "when calculator version cannot be determined" do
      before do
        allow(migration).to receive_messages(calculator_version: nil, calculator_version_accepted?: false)
      end

      it "does not remove PFC files when version is unknown" do
        project_with_v8_pfc

        migration.perform

        expect(migration).not_to have_received(:delete_funding_calculator_for)
      end
    end
  end

  describe "#projects_with_pfc" do
    let(:migration) { described_class.new }
    let!(:draft_project_with_pfc) { create(:project, :draft, funding_calculator_file_name: "calculator.xlsx") }
    let!(:archived_project_with_pfc) { create(:project, :archived, funding_calculator_file_name: "calculator.xlsx") }
    let!(:submitted_project_with_pfc) { create(:project, :submitted, funding_calculator_file_name: "calculator.xlsx") }
    let!(:draft_project_without_pfc) { create(:project, :draft) }

    it "returns only draft and archived projects with PFC files" do
      projects = migration.send(:projects_with_pfc)

      expect(projects).to contain_exactly(draft_project_with_pfc, archived_project_with_pfc)
    end

    it "excludes submitted projects" do
      projects = migration.send(:projects_with_pfc)

      expect(projects).not_to include(submitted_project_with_pfc)
    end

    it "excludes projects without PFC files" do
      projects = migration.send(:projects_with_pfc)

      expect(projects).not_to include(draft_project_without_pfc)
    end
  end

  describe "#old_pfc_version?" do
    let(:migration) { described_class.new }
    let(:project_with_pfc) { create(:project, funding_calculator_file_name: "calculator.xlsx") }
    let(:project_without_pfc) { create(:project) }

    context "when project has no PFC file" do
      it "returns false" do
        expect(migration.send(:old_pfc_version?, project_without_pfc)).to be false
      end
    end

    context "when project has PFC file with old version" do
      before do
        allow(migration).to receive_messages(calculator_version: :v8, calculator_version_accepted?: false)
      end

      it "returns true" do
        expect(migration.send(:old_pfc_version?, project_with_pfc)).to be true
      end
    end

    context "when project has PFC file with accepted version" do
      before do
        allow(migration).to receive_messages(calculator_version: :v9, calculator_version_accepted?: true)
      end

      it "returns false" do
        expect(migration.send(:old_pfc_version?, project_with_pfc)).to be false
      end
    end

    context "when calculator version cannot be determined" do
      before do
        allow(migration).to receive_messages(calculator_version: nil, calculator_version_accepted?: false)
      end

      it "returns false" do
        expect(migration.send(:old_pfc_version?, project_with_pfc)).to be false
      end
    end
  end

  describe ".perform" do
    let(:migration_instance) { instance_spy(described_class) }

    it "creates a new instance and calls perform" do
      allow(described_class).to receive(:new).and_return(migration_instance)

      described_class.perform

      expect(described_class).to have_received(:new)
      expect(migration_instance).to have_received(:perform)
    end
  end
end
