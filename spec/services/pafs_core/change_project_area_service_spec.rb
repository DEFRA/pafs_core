# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ChangeProjectAreaService do
  describe "#run" do

    subject(:service) { described_class.new(project) }

    let(:user) { create(:user, :rma, admin: false) }
    let(:rma_area_a) { create(:rma_area, name: "Allerdale Borough Council") }
    let(:rma_area_b) { create(:rma_area, name: "Barrow-in-Furness Borough Council") }
    let(:project) { create(:project, creator: user, state: create(:state, state: :draft)) }

    before do
      user.user_areas.create(area_id: rma_area_a.id, primary: true)
      project.area_projects.create(area_id: rma_area_a.id, owner: true)
      allow(Airbrake).to receive(:notify)
    end

    context "when the RMA already matches the target" do
      it "does not modify the project" do
        expect { service.run(rma_area_a) }.not_to change(project, :owner)
      end
    end

    context "with an invalid RMA" do
      it "raises an error" do
        service.run(nil)

        expect(Airbrake).to have_received(:notify)
      end
    end

    context "with a valid new RMA" do
      it "sets the RMA" do
        expect { service.run(rma_area_b) }.to change(project, :owner).to(rma_area_b)
      end

      it "updates the project's rma_name" do
        expect { service.run(rma_area_b) }.to change(project, :rma_name).to(rma_area_b.name)
      end

      it "removes the project from the user's list of visible projects" do
        service.run(rma_area_b)

        expect(PafsCore::ProjectService.new.projects_for_user(user)).not_to include(project)
      end
    end
  end
end
