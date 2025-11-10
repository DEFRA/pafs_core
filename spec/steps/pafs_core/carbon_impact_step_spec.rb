# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CarbonImpactStep, type: :model do
  subject { build(:carbon_impact_step, project: build(:full_project, :with_funding_values)) }

  let(:params) { ActionController::Parameters.new({ name: "test" }) }

  it_behaves_like "a project step"

  context "when carbon values have not changed" do
    # The carbon values hexdigest is always updated, and this triggers updates to id and creator_id
    it "does not modify project attributes other than id, creator_id and carbon_values_hexdigest" do
      unchanged_attrs = subject.project.attributes.except(:id, :creator_id, :carbon_values_hexdigest)

      expect { subject.update(params) }.not_to change { unchanged_attrs }
    end
  end

  context "when carbon values have changed" do
    before { subject.project.update(carbon_cost_build: 999) }

    it { expect { subject.update(params) }.to change { subject.project.carbon_values_hexdigest } }
  end

  describe "#presenter" do
    it "returns a CarbonImpactPresenter instance" do
      presenter = subject.presenter
      expect(presenter).to be_a(PafsCore::CarbonImpactPresenter)
    end
  end
end
