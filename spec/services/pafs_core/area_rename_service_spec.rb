# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::AreaRenameService do
  describe "#run" do
    subject(:rename_service) { described_class.new(area_type, area_name) }

    let(:old_name) { Faker::Lorem.unique.sentence }
    let(:new_name) { Faker::Lorem.unique.sentence }

    let(:area_name) { old_name }
    let(:area_type) { "RMA" }

    before { create(:rma_area, name: old_name) }

    context "when the area is not found by name" do
      let(:area_name) { "not_#{old_name}" }

      it "raises an error" do
        expect { rename_service.run(new_name) }.to raise_error(StandardError)
      end
    end

    context "when the area type does not match" do
      let(:area_type) { "PSO" }

      it "raises an error" do
        expect { rename_service.run(new_name) }.to raise_error(StandardError)
      end

      it "does not update the name" do
        expect { rename_service.run(new_name) }.not_to change(PafsCore::Area.last, :name)
      rescue StandardError # rubocop:disable Lint/SuppressedException
      end
    end

    context "when the area is found by name and the area type matches" do
      it "updates the name" do
        expect { rename_service.run(new_name) }.to change { PafsCore::Area.last.name }.to(new_name)
      end
    end
  end
end
