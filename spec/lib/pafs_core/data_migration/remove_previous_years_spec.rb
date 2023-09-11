# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::DataMigration::RemovePreviousYears do

  describe "#perform_all" do
    let!(:project_1) { create(:project) }
    let!(:project_2) { create(:project) }

    before { allow(described_class).to receive(:new).and_call_original }

    it "processes each project" do
      described_class.perform_all

      expect(described_class).to have_received(:new).with(project_1)
      expect(described_class).to have_received(:new).with(project_2)
    end
  end

  describe "#perform" do
    let(:project) { create(:project) }
    let(:step) { create(:funding_sources_step) }
    let(:current_year) { Time.zone.today.uk_financial_year }
    let(:data_start_year) { current_year - 2 }
    let(:data_end_year) { current_year + 2 }

    before do
      (data_start_year..data_end_year).each do |year|
        project.funding_values <<
          create(:funding_value, financial_year: year)
        project.flood_protection_outcomes <<
          create(:flood_protection_outcomes, financial_year: year)
        project.flood_protection2040_outcomes <<
          create(:flood_protection2040_outcomes, financial_year: year)
        project.coastal_erosion_protection_outcomes <<
          create(:coastal_erosion_protection_outcomes, financial_year: year)
      end

      described_class.new(project).perform
    end

    shared_examples "prunes year values correctly" do |attribute|
      it "removes #{attribute} values for previous years" do
        expect(project.public_send(attribute).pluck(:financial_year))
          .not_to include(current_year - 2, current_year - 1)
      end

      it "does not remove #{attribute} values for the current financial year" do
        expect(project.public_send(attribute).pluck(:financial_year))
          .to include(current_year)
      end

      it "does not remove #{attribute} values for future financial years" do
        expect(project.public_send(attribute).pluck(:financial_year))
          .to include(current_year + 1, current_year + 2)
      end
    end

    it_behaves_like "prunes year values correctly", :funding_values
    it_behaves_like "prunes year values correctly", :flood_protection_outcomes
    it_behaves_like "prunes year values correctly", :flood_protection2040_outcomes
    it_behaves_like "prunes year values correctly", :coastal_erosion_protection_outcomes
  end
end
