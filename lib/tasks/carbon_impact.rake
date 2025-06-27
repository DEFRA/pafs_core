# frozen_string_literal: true

namespace :pafs do
  desc "Export projects to Pol"
  task :carbon_impact, [:reference_number] => :environment do |_task, args|
    reference_number = args[:reference_number]

    unless reference_number
      puts "Error: Please provide a project reference number"
      puts "Usage: rake 'pafs:carbon_impact[reference_number]'"
      puts "Example: rake 'pafs:carbon_impact[WXC501E/000A/008A]'"
      exit 1
    end

    project = PafsCore::Project.find_by(reference_number: reference_number)

    unless project
      puts "Error: Project with reference number '#{reference_number}' not found"
      exit 1
    end

    print_carbon_impact_stats(project)
  end
end

def print_carbon_impact_stats(project)
  all_net_carbot_values_present = project.carbon_cost_build.present? &&
                                  project.carbon_cost_operation.present? &&
                                  project.carbon_cost_sequestered.present? &&
                                  project.carbon_cost_avoided.present?

  presenter = PafsCore::CarbonImpactPresenter.new(project: project)

  puts "** Carbon impact **"

  puts " "
  puts "** Capital **"
  puts "Capital carbon baseline (tCO2) \t\t\t\t\t #{presenter.capital_carbon_baseline} tonnes"
  puts "Capital carbon target (tCO2) \t\t\t\t\t #{presenter.capital_carbon_target} tonnes"
  puts "Capital carbon estimated by you (tCO2) \t\t\t\t #{presenter.capital_carbon_estimate} tonnes"
  puts "Capital cost calculated for the project (£) \t\t\t £#{presenter.capital_cost_estimate}"

  puts " "
  puts "** Operations and maintenance carbon **"
  puts "Operational carbon baseline (tCO2) \t\t\t\t #{presenter.operational_carbon_baseline} tonnes"
  puts "Operational carbon target (tCO2) \t\t\t\t #{presenter.operational_carbon_target} tonnes"
  puts "Operational carbon estimated by you (tCO2) \t\t\t #{presenter.operational_carbon_estimate} tonnes"
  puts "Operations and maintenance cost calculated for the project (£) \t £#{presenter.operational_cost_estimate}"
  puts " "
  puts "Sequestered carbon will the project produce (tCO2) \t\t #{presenter.sequestered_carbon_estimate} tonnes"
  puts "Carbon will be avoided by this project (tCO2) \t\t\t #{presenter.avoided_carbon_estimate} tonnes"
  unless all_net_carbot_values_present
    puts "Net carbon with blank values calculated (tCO2) \t\t\t #{presenter.net_carbon_with_blanks_calculated} tonnes"
  end
  puts "Net carbon will economically benefit the project (£) \t\t £#{presenter.net_economic_benefit_estimate}"
end
