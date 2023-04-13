# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ModerationPresenter do
  subject(:presenter) { described_class.new(project) }

  let(:project) { build(:project, :ea_area, urgency_reason: urgency_reason) }
  let(:urgency_reason) { nil }

  describe "#body" do
    before { allow(Airbrake).to receive :notify }

    it "renders the template" do
      expect { presenter.body }.not_to raise_error
    end

    it "does not report an error" do
      presenter.body

      expect(Airbrake).not_to have_received :notify
    end

    context "with a missing owner" do
      before { project.area_projects.update(owner: false) }

      it "reports an error" do
        presenter.body

        expect(Airbrake).to have_received(:notify).at_least(:once)
      end
    end
  end

  describe "#pretty_urgency_reason" do
    context "with no urgency reason" do
      let(:urgency_reason) { nil }

      it "returns an empty string" do
        expect(presenter.pretty_urgency_reason).to eq ""
      end
    end

    context "with an urgency reason" do
      let(:urgency_reason) { "statutory_need" }

      it "returns an empty string" do
        expect(presenter.pretty_urgency_reason).to eq "A business critical statutory need"
      end
    end
  end
end
