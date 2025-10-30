# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CarbonImpactPresenter do
  subject(:presenter) { described_class.new(project: project) }

  let(:project) do
    create(:project,
           start_construction_month: 6,
           start_construction_year: 2023,
           ready_for_service_month: 8,
           ready_for_service_year: 2025,
           fcerm_gia: true)
  end
  let(:pf_calculator_presenter) { instance_double(PafsCore::PartnershipFundingCalculatorPresenter) }

  before do
    create(:funding_value, project: project, financial_year: 2022, fcerm_gia: 1000, local_levy: 2000)
    create(:funding_value, project: project, financial_year: 2023, fcerm_gia: 2000, local_levy: 3000)
    create(:funding_value, project: project, financial_year: 2024, fcerm_gia: 3000, local_levy: 4000)
    create(:funding_value, project: project, financial_year: 2025, fcerm_gia: 4000, local_levy: 5000)
    create(:funding_value, project: project, financial_year: 2026, fcerm_gia: 5000, local_levy: 6000)

    allow(PafsCore::PartnershipFundingCalculatorPresenter).to receive(:new)
      .with(project: project)
      .and_return(pf_calculator_presenter)
  end

  describe "#initialize" do
    it "sets the project" do
      expect(presenter.send(:project)).to eq(project)
    end

    it "creates a partnership funding calculator presenter" do
      expect(presenter.send(:pf_calculator_presenter)).to eq(pf_calculator_presenter)
    end
  end

  describe "#capital_carbon_estimate" do
    before do
      allow(project).to receive(:carbon_cost_build).and_return(1001)
    end

    it "returns the project's carbon_cost_build" do
      expect(presenter.capital_carbon_estimate).to eq(1001)
    end
  end

  describe "#operational_carbon_estimate" do
    before do
      allow(project).to receive(:carbon_cost_operation).and_return(2000.75)
    end

    it "returns the project's carbon_cost_operation" do
      expect(presenter.operational_carbon_estimate).to eq(2000.75)
    end
  end

  describe "#total_carbon_without_mitigations" do
    before do
      allow(project).to receive_messages(carbon_cost_build: 1000.0, carbon_cost_operation: 2000.0)
    end

    it "returns the sum of capital and operational carbon estimates excluding sequestered and avoided" do
      expect(presenter.total_carbon_without_mitigations).to eq(3000.0)
    end
  end

  describe "#sequestered_carbon_estimate" do
    before do
      allow(project).to receive(:carbon_cost_sequestered).and_return(500.25)
    end

    it "returns the project's carbon_cost_sequestered" do
      expect(presenter.sequestered_carbon_estimate).to eq(500.25)
    end
  end

  describe "#avoided_carbon_estimate" do
    before do
      allow(project).to receive(:carbon_cost_avoided).and_return(750.5)
    end

    it "returns the project's carbon_cost_avoided" do
      expect(presenter.avoided_carbon_estimate).to eq(750.5)
    end
  end

  describe "#net_carbon_estimate" do
    before do
      allow(project).to receive_messages(carbon_cost_build: 1000.0, carbon_cost_operation: 2000.0, carbon_cost_sequestered: 500.0, carbon_cost_avoided: 750.0)
    end

    it "calculates net carbon as carbon total minus sequestered minus avoided" do
      expect(presenter.net_carbon_estimate).to eq(1750.0)
    end
  end

  describe "#net_economic_benefit_estimate" do
    let(:project) { create(:project, carbon_savings_net_economic_benefit: 15_000.0) }

    it "returns the project's carbon_savings_net_economic_benefit" do
      expect(presenter.net_economic_benefit_estimate).to eq(15_000.0)
    end
  end

  describe "#capital_cost_estimate_present?" do
    it "returns true if start_construction_year is present" do
      allow(project).to receive_messages(start_construction_month: 1, start_construction_year: 2024)
      expect(presenter.capital_cost_estimate_present?).to be true
    end

    it "returns false if start_construction_year is nil" do
      allow(project).to receive_messages(start_construction_month: 1, start_construction_year: nil)
      expect(presenter.capital_cost_estimate_present?).to be false
    end
  end

  describe "#capital_cost_estimate" do
    it "returns the construction total project funding" do
      expect(presenter.capital_cost_estimate).to eq(9_000.0)
    end
  end

  describe "#operational_cost_estimate_present?" do
    it "returns true if operational_total_project_funding is present" do
      allow(project).to receive(:carbon_operational_cost_forecast).and_return(500)
      expect(presenter.operational_cost_estimate_present?).to be true
    end

    it "returns false if operational_total_project_funding is nil" do
      allow(project).to receive(:carbon_operational_cost_forecast).and_return(nil)
      expect(presenter.operational_cost_estimate_present?).to be false
    end
  end

  describe "#operational_cost_estimate" do
    before do
      allow(project).to receive(:carbon_operational_cost_forecast).and_return(500)
    end

    it "returns the operation & maintenence cost forecast" do
      expect(presenter.operational_cost_estimate).to eq(500)
    end
  end

  describe "#capital_carbon_baseline" do
    it "calculates baseline from funding and intensity" do
      expect(presenter.capital_carbon_baseline).to eq(2.943)
    end
  end

  describe "#operational_carbon_baseline" do
    before do
      allow(project).to receive(:carbon_operational_cost_forecast).and_return(50_000)
    end

    it "calculates baseline from funding and intensity" do
      expect(presenter.operational_carbon_baseline).to eq(19.55)
    end
  end

  describe "#capital_carbon_target" do
    it "calculates target with reduction rate applied" do
      # 9000 * 3.27 * (1 + (-0.225)) / 10000 = 9000 * 3.27 * 0.775 / 10000
      expect(presenter.capital_carbon_target.round(4)).to eq(2.2808)
    end
  end

  describe "#operational_carbon_target" do
    before do
      allow(project).to receive(:carbon_operational_cost_forecast).and_return(50_000)
    end

    it "calculates target with reduction rate applied" do
      # 50000 * 3.91 * (1 + (-0.27)) / 10000 = 50000 * 3.91 * 0.73 / 10000
      expect(presenter.operational_carbon_target).to eq(14.2715)
    end
  end

  describe "#net_carbon_with_blanks_calculated" do
    context "when all values are present" do
      before do
        allow(project).to receive_messages(carbon_cost_build: 1000.0, carbon_cost_operation: 2000.0, carbon_cost_sequestered: 500.0, carbon_cost_avoided: 750.0)
      end

      it "uses the actual values" do
        expect(presenter.net_carbon_with_blanks_calculated).to eq(1750.0)
      end
    end

    context "when carbon_cost_build is blank" do
      before do
        allow(project).to receive_messages(carbon_cost_build: nil, carbon_cost_operation: 1750.1, carbon_cost_sequestered: 500.2, carbon_cost_avoided: 700.0)
      end

      it "uses capital_carbon_baseline as default" do
        expect(presenter.net_carbon_with_blanks_calculated.round).to eq(553)
      end
    end

    context "when carbon_cost_operation is blank" do
      before do
        allow(project).to receive(:carbon_operational_cost_forecast).and_return(50_000)
        allow(project).to receive_messages(carbon_cost_build: 1750.2, carbon_cost_operation: nil, carbon_cost_sequestered: 500.2, carbon_cost_avoided: 700.0)
      end

      it "uses operational_carbon_baseline as default" do
        expect(presenter.net_carbon_with_blanks_calculated).to eq(569.55)
      end
    end

    context "when sequestered and avoided are blank" do
      before do
        allow(project).to receive_messages(carbon_cost_build: 1000.0, carbon_cost_operation: 2000.0, carbon_cost_sequestered: nil, carbon_cost_avoided: nil)
      end

      it "defaults blank values to 0" do
        expect(presenter.net_carbon_with_blanks_calculated).to eq(3000.0)
      end
    end
  end

  describe "#all_carbon_values_nil?" do
    it "returns true if all carbon values are nil" do
      allow(project).to receive_messages(carbon_cost_build: nil, carbon_cost_operation: nil, carbon_cost_sequestered: nil, carbon_cost_avoided: nil)
      expect(presenter.all_carbon_values_nil?).to be true
    end

    it "returns false if any carbon value is present" do
      allow(project).to receive_messages(carbon_cost_build: 1000.0, carbon_cost_operation: nil, carbon_cost_sequestered: nil, carbon_cost_avoided: nil)
      expect(presenter.all_carbon_values_nil?).to be false
    end
  end

  describe "#all_carbon_values_present?" do
    it "returns true if all carbon values are present" do
      allow(project).to receive_messages(carbon_cost_build: 1000.0, carbon_cost_operation: 2000.0, carbon_cost_sequestered: 500.0, carbon_cost_avoided: 750.0)
      expect(presenter.all_carbon_values_present?).to be true
    end

    it "returns false if any carbon value is nil" do
      allow(project).to receive_messages(carbon_cost_build: 1000.0, carbon_cost_operation: nil, carbon_cost_sequestered: 500.0, carbon_cost_avoided: 750.0)
      expect(presenter.all_carbon_values_present?).to be false
    end
  end

  shared_examples "carbon field in units" do |field|
    it "returns formatted field value when present" do
      project.send("#{field}=", 1234.56)
      expect(subject.send("display_#{field}")).to eq("1,234.56 tonnes")
    end

    it "returns 'not provided' when field value is nil" do
      project.send("#{field}=", nil)
      expect(subject.send("display_#{field}")).to eq(I18n.t(".not_provided"))
    end
  end

  shared_examples "carbon field in pounds" do |field|
    it "returns formatted field value when present" do
      project.send("#{field}=", 1234)
      expect(subject.send("display_#{field}")).to eq("£1,234")
    end

    it "returns 'not provided' when field value is nil" do
      project.send("#{field}=", nil)
      expect(subject.send("display_#{field}")).to eq(I18n.t(".not_provided"))
    end
  end

  describe "#display_carbon_cost_build" do
    it_behaves_like "carbon field in units", :carbon_cost_build
  end

  describe "#display_carbon_cost_operation" do
    it_behaves_like "carbon field in units", :carbon_cost_operation
  end

  describe "#display_total_carbon_without_mitigations" do
    it "returns 'not provided' when all required fields are nil" do
      project.carbon_cost_build = nil
      project.carbon_cost_operation = nil
      expect(subject.display_total_carbon_without_mitigations).to eq(I18n.t(".not_provided"))
    end

    it "returns formatted field value when at least one is present" do
      project.carbon_cost_build = 1000.00
      expect(subject.display_total_carbon_without_mitigations).to eq("1,000.00 tonnes")
    end

    it "returns formatted field value with custom units" do
      project.carbon_cost_build = 1234.56
      expect(subject.display_total_carbon_without_mitigations(units: "metric tonnes")).to eq("1,234.56 metric tonnes")
    end
  end

  describe "#display_carbon_cost_sequestered" do
    it_behaves_like "carbon field in units", :carbon_cost_sequestered
  end

  describe "#display_carbon_cost_avoided" do
    it_behaves_like "carbon field in units", :carbon_cost_avoided
  end

  describe "#display_net_carbon_estimate" do
    it "returns 'not provided' when all required fields are nil" do
      project.carbon_cost_build = nil
      project.carbon_cost_operation = nil
      project.carbon_cost_sequestered = nil
      project.carbon_cost_avoided = nil
      expect(subject.display_net_carbon_estimate).to eq(I18n.t(".not_provided"))
    end

    it "returns formatted field value when at least one carbon field is present" do
      project.carbon_cost_build = 500.00
      expect(subject.display_net_carbon_estimate).to eq("500.00 tonnes")
    end

    it "returns formatted field value with custom units" do
      project.carbon_cost_build = 1234.56
      expect(subject.display_net_carbon_estimate(units: "metric tonnes")).to eq("1,234.56 metric tonnes")
    end
  end

  describe "#display_carbon_savings_net_economic_benefit" do
    it_behaves_like "carbon field in pounds", :carbon_savings_net_economic_benefit
  end

  describe "#display_carbon_operational_cost_forecast" do
    it_behaves_like "carbon field in pounds", :carbon_operational_cost_forecast
  end

  describe "#display_capital_cost_estimate" do
    it "returns 'not provided' when field value is nil" do
      allow(project).to receive_messages(start_construction_month: 1, start_construction_year: nil)
      expect(subject.display_capital_cost_estimate).to eq(I18n.t(".not_provided"))
    end

    it "returns formatted field value when present" do
      allow(project).to receive_messages(start_construction_month: 1, start_construction_year: 2025)
      expect(subject.display_capital_cost_estimate).to include("£")
    end
  end

  describe "#display_capital_carbon_estimate" do
    it "returns formatted carbon value with units" do
      allow(project).to receive(:carbon_cost_build).and_return(1234.56)
      expect(subject.display_capital_carbon_estimate).to eq("1,234.56 tonnes")
    end

    it "returns 'not provided' when carbon_cost_build is nil" do
      allow(project).to receive(:carbon_cost_build).and_return(nil)
      expect(subject.display_capital_carbon_estimate).to eq(I18n.t(".not_provided"))
    end
  end

  describe "#display_capital_carbon_baseline" do
    it "returns formatted carbon baseline with units" do
      expect(subject.display_capital_carbon_baseline).to eq("2.94 tonnes")
    end

    it "returns 'not provided' when start_construction_year is nil" do
      allow(project).to receive_messages(start_construction_month: 1, start_construction_year: nil)
      expect(subject.display_capital_carbon_baseline).to eq(I18n.t(".not_provided"))
    end
  end

  describe "#display_capital_carbon_target" do
    it "returns formatted carbon target with units" do
      expect(subject.display_capital_carbon_target).to eq("2.28 tonnes")
    end

    it "returns 'not provided' when start_construction_year is nil" do
      allow(project).to receive_messages(start_construction_month: 1, start_construction_year: nil)
      expect(subject.display_capital_carbon_target).to eq(I18n.t(".not_provided"))
    end
  end

  describe "#display_operational_carbon_estimate" do
    it "returns formatted carbon value with units" do
      allow(project).to receive(:carbon_cost_operation).and_return(1234.56)
      expect(subject.display_operational_carbon_estimate).to eq("1,234.56 tonnes")
    end

    it "returns 'not provided' when carbon_cost_operation is nil" do
      allow(project).to receive(:carbon_cost_operation).and_return(nil)
      expect(subject.display_operational_carbon_estimate).to eq(I18n.t(".not_provided"))
    end
  end

  describe "#display_operational_carbon_baseline" do
    it "returns formatted carbon baseline with units" do
      allow(project).to receive(:carbon_operational_cost_forecast).and_return(12_345)
      expect(subject.display_operational_carbon_baseline).to eq("4.83 tonnes")
    end

    it "returns 'not provided' if operational_total_project_funding is nil" do
      allow(pf_calculator_presenter).to receive(:attributes).and_return({ pv_future_costs: nil })
      expect(subject.display_operational_carbon_baseline).to eq(I18n.t(".not_provided"))
    end
  end

  describe "#display_operational_carbon_target" do
    it "returns formatted carbon target with units" do
      allow(project).to receive(:carbon_operational_cost_forecast).and_return(12_345)
      expect(subject.display_operational_carbon_target).to eq("3.52 tonnes")
    end

    it "returns 'not provided' if operational_total_project_funding is nil" do
      allow(pf_calculator_presenter).to receive(:attributes).and_return({ pv_future_costs: nil })
      expect(subject.display_operational_carbon_target).to eq(I18n.t(".not_provided"))
    end
  end

  describe "#display_net_carbon_with_blanks_calculated" do
    it "returns formatted carbon value with units" do
      allow(project).to receive_messages(carbon_cost_build: 1234.56, carbon_cost_operation: 1234.56)
      expect(subject.display_net_carbon_with_blanks_calculated).to eq("2,469.12 tonnes")
    end

    it "returns 'not provided' when net_carbon_with_blanks_calculated is nil" do
      presenter = described_class.new(project: project)
      allow(presenter).to receive(:net_carbon_with_blanks_calculated).and_return(nil)
      expect(presenter.display_net_carbon_with_blanks_calculated).to eq(I18n.t(".not_provided"))
    end
  end

  describe "protected methods" do
    describe "#start_construction_financial_year" do
      context "when start_construction_month is before April" do
        let(:project) { create(:project, start_construction_month: 2, start_construction_year: 2024) }

        it "returns previous year" do
          expect(presenter.send(:start_construction_financial_year)).to eq(2023)
        end
      end

      context "when start_construction_month is April or later" do
        let(:project) { create(:project, start_construction_month: 4, start_construction_year: 2024) }

        it "returns the same year" do
          expect(presenter.send(:start_construction_financial_year)).to eq(2024)
        end
      end
    end

    describe "#ready_for_service_financial_year" do
      context "when ready_for_service_month is before April" do
        let(:project) { create(:project, ready_for_service_month: 3, ready_for_service_year: 2025) }

        it "returns previous year" do
          expect(presenter.send(:ready_for_service_financial_year)).to eq(2024)
        end
      end

      context "when ready_for_service_month is April or later" do
        let(:project) { create(:project, ready_for_service_month: 5, ready_for_service_year: 2025) }

        it "returns the same year" do
          expect(presenter.send(:ready_for_service_financial_year)).to eq(2025)
        end
      end
    end

    describe "#mid_year" do
      it "calculates the middle year between construction and service" do
        expect(presenter.send(:mid_year)).to eq(2024)
      end
    end

    describe "#mid_year_formatted" do
      it "formats as financial year string" do
        expect(presenter.send(:mid_year_formatted)).to eq("2024/25")
      end
    end

    describe "#ready_for_service_year_formatted" do
      it "formats as financial year string" do
        expect(presenter.send(:ready_for_service_year_formatted)).to eq("2025/26")
      end
    end

    describe "#carbon_impact_rates" do
      let(:json_content) do
        {
          "carbon_impact_rates" => [
            { "Year" => "2023/24", "Cap Do Nothing Intensity" => 3.5 }
          ]
        }.to_json
      end

      before do
        allow(File).to receive(:read).and_return(json_content)
      end

      it "loads carbon impact rates from JSON file" do
        rates = presenter.send(:carbon_impact_rates)
        expect(rates).to be_an(Array)
        expect(rates.first["Year"]).to eq("2023/24")
      end
    end

    describe "#carbon_impact_rate_for_year" do
      let(:json_content) do
        {
          "carbon_impact_rates" => [
            { "Year" => "2022/23", "Cap Do Nothing Intensity" => 3.0, "Cap Target Reduction Rate" => -10.0 },
            { "Year" => "2023/24", "Cap Do Nothing Intensity" => 3.5, "Cap Target Reduction Rate" => nil },
            { "Year" => "2024/25", "Cap Do Nothing Intensity" => 4.0, "Cap Target Reduction Rate" => -20.0 }
          ]
        }.to_json
      end

      before do
        allow(File).to receive(:read).and_return(json_content)
      end

      context "when the rate is present for the requested year" do
        it "returns the rate for the specific year" do
          rate = presenter.send(:carbon_impact_rate_for_year, "2023/24", "Cap Do Nothing Intensity")
          expect(rate).to eq(3.5)
        end
      end

      context "when the rate is not present for the requested year" do
        it "returns the first available rate from previous years" do
          rate = presenter.send(:carbon_impact_rate_for_year, "2027/28", "Cap Target Reduction Rate")
          expect(rate).to eq(-20.0)
        end
      end
    end

    describe "#construction_total_project_funding" do
      it "sums funding values for construction years only" do
        # Construction years are 2023, 2024, 2025
        expect(presenter.send(:construction_total_project_funding)).to eq(9_000)
      end
    end

    describe "#operational_total_project_funding" do
      before do
        allow(project).to receive(:carbon_operational_cost_forecast).and_return(75_000)
      end

      it "returns pv_future_costs from partnership funding calculator" do
        expect(presenter.send(:operational_total_project_funding)).to eq(75_000.0)
      end
    end
  end
end
