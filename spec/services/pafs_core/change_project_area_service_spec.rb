# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ChangeProjectAreaService do
  describe "#run" do

    subject(:service) { described_class.new(project_number) }

    let!(:rma_a) { create(:rma_area, name: "Allerdale Borough Council") }
    let(:rma_b) { create(:rma_area, name: "Barrow-in-Furness Borough Council") }
    let!(:project_a) { create(:project, reference_number: project_number) }
    let!(:area_project_a) { create(:area_project, area: rma_a, project: project_a) }
    let(:project_number) { "NWC501E/000A/042A" }

    context "with an invalid project number" do
      let(:project_number) { "NWC501E/000Z/053X" }

      it "raises an error" do
        expect(service.run("foo")).to raise_error(StandardError)
      rescue StandardError # rubocop:disable Lint/SuppressedException
      end
    end

    context "when the RMA already matches the target" do
      it "does not modify the project" do
        expect { service.run(rma_a.name) }.not_to change { project_a.areas.first }
      end
    end

    context "when the specified target RMA does not exist" do
      it "raises an error" do
        expect(service.run("foo")).to raise_error(StandardError)
      rescue StandardError # rubocop:disable Lint/SuppressedException
      end
    end

    context "with a valid project number and RMA" do
      it "sets the RMA" do
        expect { service.run(rma_b.name) }.to change { project_a.areas.first }.to(rma_b)
      end
    end
  end
end
