# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ChangeProjectAreaService do
  describe "#run" do

    subject(:service) { described_class.new(project_a) }

    let!(:rma_a) { create(:rma_area, name: "Allerdale Borough Council") }
    let(:rma_b) { create(:rma_area, name: "Barrow-in-Furness Borough Council") }
    let!(:project_a) { create(:project) }
    let!(:area_project_a) { create(:area_project, area: rma_a, project: project_a, owner: true) }

    before { allow(Airbrake).to receive(:notify) }

    context "when the RMA already matches the target" do
      it "does not modify the project" do
        expect { service.run(rma_a) }.not_to change(project_a, :owner)
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
        expect { service.run(rma_b) }.to change(project_a, :owner).to(rma_b)
      end

      it "updates the project's rma_name" do
        expect { service.run(rma_b) }.to change(project_a, :rma_name).to(rma_b.name)
      end
    end
  end
end
