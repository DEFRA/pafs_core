# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::RemovePreviousYearsService do
  describe "#run" do

    subject(:service) { described_class.new(project) }

    let(:project) { create(:project) }
    let(:current_year) { Time.zone.today.uk_financial_year }
    let(:data_start_year) { current_year - 2 }
    let(:data_end_year) { current_year + 2 }

    before do

      project.state.update(state: state)

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

      described_class.new(project).run
    end

    shared_examples "removes previous year values" do |attribute|
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

    shared_examples "removes previous years values for financial year attributes" do
      it_behaves_like "removes previous year values", :funding_values
      it_behaves_like "removes previous year values", :flood_protection_outcomes
      it_behaves_like "removes previous year values", :flood_protection2040_outcomes
      it_behaves_like "removes previous year values", :coastal_erosion_protection_outcomes
    end

    shared_examples "does not remove previous year values" do |attribute|
      it "does not remove #{attribute} values for any year" do
        expect(project.public_send(attribute).pluck(:financial_year))
          .to include(current_year - 2, current_year + 2)
      end
    end

    context "with a submitted project" do
      let(:state) { "submitted" }

      it_behaves_like "does not remove previous year values", :funding_values
      it_behaves_like "does not remove previous year values", :flood_protection_outcomes
      it_behaves_like "does not remove previous year values", :flood_protection2040_outcomes
      it_behaves_like "does not remove previous year values", :coastal_erosion_protection_outcomes
    end

    context "with a draft project" do
      let(:state) { "draft" }

      it_behaves_like "removes previous years values for financial year attributes"
    end

    context "with an archived project" do
      let(:state) { "archived" }

      it_behaves_like "removes previous years values for financial year attributes"
    end
  end
end
