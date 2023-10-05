# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::DataMigration::RemovePreviousYears do

  describe "#perform_all" do
    let(:projects_with_previous_years_data) do
      create_list(:project, 5, funding_values: [],
                               flood_protection_outcomes: [],
                               flood_protection2040_outcomes: [],
                               coastal_erosion_protection_outcomes: [])
    end
    let(:projects_without_previous_years_data) do
      create_list(:project, 2, funding_values: [],
                               flood_protection_outcomes: [],
                               flood_protection2040_outcomes: [],
                               coastal_erosion_protection_outcomes: [])
    end
    let(:current_year) { Time.zone.today.uk_financial_year }
    let(:data_start_year) { current_year - 2 }
    let(:data_end_year) { current_year + 2 }

    before do
      projects_with_previous_years_data.each do |project|
        (data_start_year..data_end_year).each do |year|
          add_financial_year_data(project, year)
        end
      end
      projects_without_previous_years_data.each do |project|
        (current_year..data_end_year - 1).each do |year|
          add_financial_year_data(project, year)
        end
      end

      allow(described_class).to receive(:new).and_call_original
      allow(PafsCore::RemovePreviousYearsService).to receive(:new).and_call_original
    end

    context "with a project limit greater than the number of qualifying projects" do

      it "processes all projects with previous years data" do
        described_class.perform(10)

        expect(PafsCore::RemovePreviousYearsService).to have_received(:new)
          .exactly(projects_with_previous_years_data.length).times
      end
    end

    context "with a project limit less than the number of qualifying projects" do

      it "processes only the specified number of projects" do
        described_class.perform(3)

        expect(PafsCore::RemovePreviousYearsService).to have_received(:new)
          .exactly(3).times
      end
    end

    context "when a project has outcomes but not funding values for previous years" do
      let(:project) { projects_without_previous_years_data.sample }

      before do
        project.flood_protection_outcomes <<
          create(:flood_protection_outcomes, project: project, financial_year: current_year - 1)
      end

      it "processes the project" do
        described_class.perform

        expect(PafsCore::RemovePreviousYearsService).to have_received(:new).with(project)
      end
    end

    context "when a project is in a submitted state" do
      let(:submitted_project) { projects_with_previous_years_data.sample }

      before { submitted_project.state.update(state: "submitted") }

      it "does not call the service for the submitted project" do
        described_class.perform

        expect(PafsCore::RemovePreviousYearsService).not_to have_received(:new).with(submitted_project)
      end
    end
  end

  def add_financial_year_data(project, year)
    project.funding_values <<
      create(:funding_value, project: project, financial_year: year)
    project.flood_protection_outcomes <<
      create(:flood_protection_outcomes, project: project, financial_year: year)
    project.flood_protection2040_outcomes <<
      create(:flood_protection2040_outcomes, project: project, financial_year: year)
    project.coastal_erosion_protection_outcomes <<
      create(:coastal_erosion_protection_outcomes, project: project, financial_year: year)
  end
end
