# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::AreaImporter do
  describe "#import" do
    it "successfully imports the areas with correct data" do
      file_path = Rails.root.join("../fixtures/areas/areas.csv")
      described_class.new.full_import(file_path)
      areas = PafsCore::Area.all
      expect(areas.size).to eq(4)
    end

    it "does not import faulty data" do
      file_path = Rails.root.join("../fixtures/areas/faulty_areas_data.csv")
      described_class.new.full_import(file_path)
      areas = PafsCore::Area.all
      expect(areas.size).to eq(3)
    end
  end

  describe "#import_additional_areas" do
    before do
      file_path = Rails.root.join("../fixtures/areas/areas.csv")
      described_class.new.full_import(file_path)
    end

    it "successfully imports the new areas with correct data" do
      file_path = Rails.root.join("../fixtures/areas/new_areas_1.csv")

      described_class.new.import_additional_areas(file_path)

      expect(PafsCore::Area.count).to eq(5)
    end

    it "does not import areas that are already present" do
      file_path = Rails.root.join("../fixtures/areas/new_areas_1.csv")

      2.times { described_class.new.import_additional_areas(file_path) }

      expect(PafsCore::Area.count).to eq(5)
    end

    it "does not import areas that have faulty data" do
      file_path = Rails.root.join("../fixtures/areas/new_faulty_areas.csv")

      described_class.new.import_additional_areas(file_path)

      expect(PafsCore::Area.count).to eq(4)
    end
  end
end
