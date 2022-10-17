# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::AreaImporter do
  describe "#import" do
    it "successfully imports the areas with correct data" do
      file_path = "#{Rails.root}/../fixtures/areas.csv"
      described_class.new.import(file_path)
      areas = PafsCore::Area.all
      expect(areas.size).to eq(4)
    end

    it "does not import faulty data" do
      file_path = "#{Rails.root}/../fixtures/faulty_areas_data.csv"
      described_class.new.import(file_path)
      areas = PafsCore::Area.all
      expect(areas.size).to eq(3)
    end
  end

  describe "#import_new_areas" do
    before do
      file_path = "#{Rails.root}/../fixtures/areas.csv"
      described_class.new.import(file_path)
    end

    it "successfully imports the new areas with correct data" do
      folder_path = "#{Rails.root}/../fixtures/new_areas"

      described_class.new.import_new_areas(folder_path)

      areas = PafsCore::Area.all
      expect(areas.size).to eq(6)
    end

    it "does not import areas that are already present" do
      folder_path = "#{Rails.root}/../fixtures/new_areas"

      2.times { described_class.new.import_new_areas(folder_path) }

      areas = PafsCore::Area.all
      expect(areas.size).to eq(6)
    end

    it "does not import areas that have faulty data" do
      folder_path = "#{Rails.root}/../fixtures/new_areas_with_faults"

      described_class.new.import_new_areas(folder_path)

      areas = PafsCore::Area.all
      expect(areas.size).to eq(5)
    end
  end
end
