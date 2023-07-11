# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::SpreadsheetPresenter do
  subject(:presenter) { described_class.new(project) }

  let(:project_type) { "DEF" }
  let(:project) { build(:project, project_type:) }

  describe "#moderation_code" do
    context "with an urgent project" do
      let(:project) { build(:project, urgency_reason: :legal_need) }

      it "returns the correct moderation code" do
        expect(presenter.moderation_code).to eql("Legal Agreement")
      end
    end

    context "with a non urgent project" do
      let(:project) { build(:project, urgency_reason: :not_urgent) }

      it 'returns "Not Urgent"' do
        expect(presenter.moderation_code).to eql("Not Urgent")
      end
    end
  end

  describe "#designated_site" do
    context "when improve_spa_or_sac is set" do
      before { project.improve_spa_or_sac = true }

      it "returns 'SPA/SAC'" do
        expect(presenter.designated_site).to eq "SPA/SAC"
      end
    end

    context "when improve_sssi is set" do
      before { project.improve_sssi = true }

      it "returns 'SSSI'" do
        expect(presenter.designated_site).to eq "SSSI"
      end
    end

    context "when neither improve_spa_or_sac nor improve_sssi is set" do
      it "returns nil" do
        expect(presenter.designated_site).to be_nil
      end
    end
  end

  describe "#remove_fish_or_eel_barrier" do
    context "when neither remove_fish_barrier nor remove_eel_barrier are set" do
      it "returns nil" do
        expect(presenter.remove_fish_or_eel_barrier).to be_nil
      end
    end

    context "when remove_eel_barrier is set" do
      before { project.remove_eel_barrier = true }

      it "returns 'Eel'" do
        expect(presenter.remove_fish_or_eel_barrier).to eq "Eel"
      end
    end

    context "when remove_fish_barrier is set" do
      before { project.remove_fish_barrier = true }

      it "returns 'Fish'" do
        expect(presenter.remove_fish_or_eel_barrier).to eq "Fish"
      end

      context "when remove_eel_barrier is also set" do
        before { project.remove_eel_barrier = true }

        it "returns 'Both'" do
          expect(presenter.remove_fish_or_eel_barrier).to eq "Both"
        end
      end
    end
  end

  describe "#last_updated" do
    let(:project) { create(:project) }

    it "returns the project's updated_at value" do
      expect(presenter.last_updated).to eq project.updated_at.strftime("%Y-%m-%d_%H-%M-%S")
    end
  end

  describe "#pso_name" do
    context "when the project's creator's primary area is a PSO area" do
      let(:project) { create(:project, :pso_area, creator: create(:user, :pso)) }

      it "returns the PSO area's name" do
        expect(presenter.pso_name).to eq project.creator.primary_area.name
      end
    end

    context "when the project's creator's primary area is an RMA area" do
      let(:project) { create(:project, :rma_area, creator: create(:user, :rma)) }

      it "returns the RMA area's parent's name" do
        expect(presenter.pso_name).to eq project.creator.primary_area.parent.name
      end
    end

    context "when the project's creator is nil" do
      let(:project) { create(:project, :rma_area, creator: nil) }

      it "returns nil" do
        expect(presenter.pso_name).to be_nil
      end
    end
  end

  describe "#project_type" do
    context "when the project type is 'STR'" do
      let(:project_type) { "STR" }

      it { expect(presenter.project_type).to eq "STR" }
    end

    context "when the project type is 'ENV_WITH_HOUSEHOLDS'" do
      let(:project_type) { "ENV_WITH_HOUSEHOLDS" }

      it { expect(presenter.project_type).to eq "ENV" }
    end

    context "when the project type is 'ENV_WITHOUT_HOUSEHOLDS'" do
      let(:project_type) { "ENV_WITHOUT_HOUSEHOLDS" }

      it { expect(presenter.project_type).to eq "ENN" }
    end
  end
end
