# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::SpreadsheetPresenter do
  subject(:presenter) { described_class.new(project) }

  let(:project) { build(:project) }

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
end
