# frozen_string_literal: true

module PafsCore
  class CarbonImpactPresenter

    def initialize(project:)
      self.project = project

      self.pf_calculator_presenter = PartnershipFundingCalculatorPresenter.new(project: project)
    end

    # How much capital carbon will the project produce (tCO2)?
    def capital_carbon_estimate
      project.carbon_cost_build || 0
    end

    # How much operational carbon will the project produce (tCO2)?
    def operational_carbon_estimate
      project.carbon_cost_operation || 0
    end

    # This is the whole life carbon calculated for the project (tCO2)
    def total_carbon_without_mitigations
      capital_carbon_estimate + operational_carbon_estimate
    end

    # How much sequestered carbon will the project produce (tCO2)
    def sequestered_carbon_estimate
      project.carbon_cost_sequestered || 0
    end

    # How much carbon will be avoided by this project (tCO2)?
    def avoided_carbon_estimate
      project.carbon_cost_avoided || 0
    end

    # This is the net carbon calculated for the project (tCO2)
    def net_carbon_estimate
      total_carbon_without_mitigations - sequestered_carbon_estimate - avoided_carbon_estimate
    end

    # How much net carbon will economically benefit the project ?
    def net_economic_benefit_estimate
      project.carbon_savings_net_economic_benefit
    end

    def capital_cost_estimate_present?
      construction_total_project_funding.present?
    rescue StandardError
      false
    end

    # Capital TPF / The estimated capital cost for the project
    def capital_cost_estimate
      construction_total_project_funding
    end

    def operational_cost_estimate_present?
      pf_calculator_presenter.attributes[:pv_future_costs].present?
    rescue StandardError
      false
    end

    # Ops TPF / The estimated operation and maintenance cost
    def operational_cost_estimate
      operational_total_project_funding
    end

    # Cap Bl / Calculated capital carbon baseline
    def capital_carbon_baseline
      construction_total_project_funding * mid_year_cap_do_nothing_intensity / 10_000
    end

    # Ops Bl / Operations and maintenance carbon baseline
    def operational_carbon_baseline
      operational_total_project_funding * gw4_ops_do_nothing_intensity / 10_000
    end

    # Cap Tgt / Calculated capital carbon target
    def capital_carbon_target
      construction_total_project_funding * mid_year_cap_do_nothing_intensity *
        (1 + mid_year_cap_target_reduction_rate) / 10_000
    end

    # Ops Tgt / Operations and maintenance carbon target
    def operational_carbon_target
      operational_total_project_funding * gw4_ops_do_nothing_intensity *
        (1 + gw4_ops_target_reduction_rate) / 10_000
    end

    # Net carbon with blank values calculated
    def net_carbon_with_blanks_calculated
      # defaults to capital_carbon_baseline when blank
      carbon_cost_build = project.carbon_cost_build.presence || capital_carbon_baseline
      # defaults to operational_carbon_baseline when blank
      carbon_cost_operation = project.carbon_cost_operation.presence || operational_carbon_baseline
      # defaults to 0 when blank
      carbon_cost_sequestered = project.carbon_cost_sequestered.presence || 0
      # defaults to 0 when blank
      carbon_cost_avoided = project.carbon_cost_avoided.presence || 0

      carbon_cost_build + carbon_cost_operation - carbon_cost_sequestered - carbon_cost_avoided
    end

    protected

    attr_accessor :project, :pf_calculator_presenter

    def start_construction_financial_year
      project.start_construction_month < 4 ? project.start_construction_year - 1 : project.start_construction_year
    end

    def ready_for_service_financial_year
      project.ready_for_service_month < 4 ? project.ready_for_service_year - 1 : project.ready_for_service_year
    end

    # Mid year of Construction start date and Ready for service. Earliest of 2 where even numbers of years
    def mid_year
      (start_construction_financial_year + ready_for_service_financial_year).div(2)
    end

    # CON Mid Yr / mid year formatted as financial year string, e.g. 2025/26
    def mid_year_formatted
      "#{mid_year}/#{(mid_year + 1) % 100}"
    end

    # GW4 Yr / ready for service year formatted as financial year string, e.g. 2025/26
    def ready_for_service_year_formatted
      "#{ready_for_service_financial_year}/#{(ready_for_service_financial_year + 1) % 100}"
    end

    def carbon_impact_rates
      json = JSON.parse(File.read(PafsCore::Engine.root.join("config", "carbon_impact_rates.json")))
      json["carbon_impact_rates"]
    end

    # Where a rate is not populated for a particular FY (or the FY does not exist in the rate table),
    # utilise the latest available rate e.g. if MidYr is 2030/31 then Cap Do Nothing Intensity
    # of 3.5 would be picked up from the 2028/29 field as this is the latest available year.
    def carbon_impact_rate_for_year(year_string, rate_label)
      rate_not_present_in_mid_year_data = false

      carbon_impact_rates.reverse.each do |rates|
        if rates["Year"] == year_string
          return rates[rate_label] if rates[rate_label].present?

          rate_not_present_in_mid_year_data = true
        end

        return rates[rate_label] if rate_not_present_in_mid_year_data && rates[rate_label].present?
      end
    end

    # Cap DN / Cap Do Nothing Intensity rate for the mid year
    def mid_year_cap_do_nothing_intensity
      carbon_impact_rate_for_year(mid_year_formatted, "Cap Do Nothing Intensity")
    end

    # Ops DN / Cap Do Nothing Intensity rate for the ready for service year
    def gw4_ops_do_nothing_intensity
      carbon_impact_rate_for_year(ready_for_service_year_formatted, "Ops Do Nothing Intensity")
    end

    # Cap Reduc % / Cap Target Reduction Rate for the mid year
    def mid_year_cap_target_reduction_rate
      carbon_impact_rate_for_year(mid_year_formatted, "Cap Target Reduction Rate") / 100
    end

    # Ops Reduc % / Ops Target Reduction Rate for the ready for service year
    def gw4_ops_target_reduction_rate
      carbon_impact_rate_for_year(ready_for_service_year_formatted, "Ops Target Reduction Rate") / 100
    end

    def construction_total_project_funding
      construction_years = (start_construction_financial_year..ready_for_service_financial_year)
      project.funding_values.select { |x| construction_years.include?(x.financial_year) }.sum(&:total)
    end

    def operational_total_project_funding
      pf_calculator_presenter.attributes[:pv_future_costs] || 0
    end
  end
end
