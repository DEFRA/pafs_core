# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::DataMigration::UpdateAuthorities do

  describe "#up" do
    it "adds authorities records if not present" do
      expect(PafsCore::Area.authorities.count).to eq(0)
      described_class.up
      expect(PafsCore::Area.authorities.count).to eq(7)
    end

    it "adds missing authorities records" do
      create(:authority, name: "Environment Agency", identifier: "EA")
      expect(PafsCore::Area.authorities.count).to eq(1)
      described_class.up
      expect(PafsCore::Area.authorities.count).to eq(7)
    end
  end

  describe "#down" do
    it "removes authorities records" do
      create(:authority, name: "Environment Agency", identifier: "EA")
      described_class.down
      expect(PafsCore::Area.authorities.count).to eq(0)
    end
  end
end
