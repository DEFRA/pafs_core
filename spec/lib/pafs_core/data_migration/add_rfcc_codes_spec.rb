# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::DataMigration::AddRfccCodes do

  describe "#up" do
    it "updates RFCC codes for PSO records" do
      pso = build(:pso_area, name: "PSO Berkshire and Buckinghamshire", sub_type: nil)
      pso.save!(validate: false)

      described_class.up
      expect(pso.reload.sub_type).to eq("TH")
    end
  end

  describe "#down" do
    it "removes RFCC codes from PSOuthorities records" do
      pso = create(:pso_area, name: "PSO Berkshire and Buckinghamshire", sub_type: "TH")
      described_class.down
      expect(pso.reload.sub_type).to eq("TH")
    end
  end
end
