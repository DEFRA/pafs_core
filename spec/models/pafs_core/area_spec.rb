# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::Area do
  describe "attributes" do
    area_levels = [
      {
        level: :country,
        parent_id: nil
      },
      {
        level: :ea_area,
        parent_id: 1
      },
      {
        level: :pso_area,
        parent_id: 1
      },
      {
        level: :rma_area,
        parent_id: 1
      }
    ]
    area = area_levels.sample
    subject { create(area[:level], parent_id: area[:parent_id]) }

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :area_type }
    it { is_expected.to validate_inclusion_of(:area_type).in_array(PafsCore::Area::AREA_TYPES) }

    context "when Country" do
      subject { create(:country) }

      it { is_expected.to validate_absence_of :parent_id }
      it { is_expected.not_to validate_presence_of :sub_type }
    end

    context "when EA area" do
      subject { create(:ea_area, parent_id: 1) }

      it { is_expected.to validate_presence_of :parent_id }
      it { is_expected.not_to validate_presence_of :sub_type }
    end

    context "when PSO area" do
      subject { create(:pso_area, parent_id: 1) }

      it { is_expected.to validate_presence_of :parent_id }
      it { is_expected.to validate_presence_of :sub_type }
    end

    context "when RMA area" do
      subject { create(:rma_area, parent_id: 1) }

      it { is_expected.to validate_presence_of :identifier }
      it { is_expected.to validate_presence_of :parent_id }
      it { is_expected.to validate_presence_of :sub_type }
    end

    context "when Authority" do
      subject { create(:authority) }

      it { is_expected.to validate_presence_of :identifier }
      it { is_expected.not_to validate_presence_of :end_date }
    end
  end

  describe "#country?" do
    subject { create(:country) }

    it "returns true when :area_type == 'Country'" do
      expect(subject.country?).to be true
    end
  end

  describe ".ea_areas" do
    subject { create(:ea_area, parent_id: 1) }

    it "returns EA areas" do
      subject.reload
      areas = described_class.ea_areas
      expect(areas.length).to eq(1)
      expect(areas.first).to eq subject
    end
  end

  describe "#ea_area?" do
    subject { create(:ea_area, parent_id: 1) }

    it "returns true when :area_type == 'EA Area'" do
      expect(subject.ea_area?).to be true
    end
  end

  describe ".pso_areas" do
    subject { create(:pso_area, parent_id: 1) }

    it "returns PSO areas" do
      subject.reload
      areas = described_class.pso_areas
      expect(areas.length).to eq(1)
      expect(areas.first).to eq subject
    end
  end

  describe "#pso_area?" do
    subject { create(:pso_area, parent_id: 1) }

    it "returns true when :area_type == 'PSO Area'" do
      expect(subject.pso_area?).to be true
    end
  end

  describe ".rma_areas" do
    subject { create(:rma_area, parent_id: 1) }

    it "returns rma areas" do
      subject.reload
      areas = described_class.rma_areas
      expect(areas.length).to eq(1)
      expect(areas.first).to eq subject
    end
  end

  describe "#rma?" do
    subject { create(:rma_area, parent_id: 1) }

    it "returns true when :area_type == 'RMA'" do
      expect(subject.rma?).to be true
    end
  end
end
