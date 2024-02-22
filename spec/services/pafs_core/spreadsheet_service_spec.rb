# frozen_string_literal: true

require "rails_helper"

class SpreadsheetMapperHelper
  extend PafsCore::Fcerm1
end

RSpec.describe PafsCore::SpreadsheetService do
  subject { described_class.new }

  describe "#generate_multi_xlsx" do
    let(:first_row) { expected.worksheets[0][6] }
    let(:second_row) { expected.worksheets[0][7] }
    let(:third_row) { expected.worksheets[0][8] }
    let(:fourth_row) { expected.worksheets[0][9] }
    let(:fifth_row) { expected.worksheets[0][10] }
    let(:filename) { "expected_program_spreadsheet.xlsx" }
    let(:content_type) { "text/plain" }
    let(:test_project_1) { create(:project, :with_funding_values, name: "Test Project 1") }

    let(:file_path) { Rails.root.join("..", "fixtures", filename) }
    let(:file) { File.open(file_path) }
    let(:projects) { PafsCore::Project.order(:name) }
    let(:expected) { subject.generate_multi_xlsx(projects) }

    let(:spreadsheet_presenter_1) { PafsCore::SpreadsheetPresenter.new(test_project_1) }

    let(:user) { create(:user, :rma) }

    let(:pso_area) { PafsCore::Area.find_by(name: "PSO Test Area") }
    let(:rma_area) { PafsCore::Area.find_by(name: "RMA Test Area") }

    before do
      file_path = Rails.root.join("../fixtures/test_areas.csv")
      PafsCore::AreaImporter.new.full_import(file_path)

      pso_area.area_projects.create(project: test_project_1, owner: true)

      # The test projects loaded from expected_program_spreadsheet.xlsx don't have owners
      test_project_1.creator = user
      test_project_1.save!
    end

    it "includes the project reference number" do
      expect(first_row[SpreadsheetMapperHelper.column_index("A")].value).to eql(spreadsheet_presenter_1.reference_number)
    end

    it "includes column B" do
      expect(first_row[SpreadsheetMapperHelper.column_index("B")].value).to eql(spreadsheet_presenter_1.name)
    end

    it "includes column AF" do
      expect(first_row[SpreadsheetMapperHelper.column_index("AF")].value).to eql(spreadsheet_presenter_1.earliest_start_date)
    end

    it "includes column AG" do
      expect(first_row[SpreadsheetMapperHelper.column_index("AG")].value).to eql(spreadsheet_presenter_1.earliest_start_date_with_gia_available)
    end

    it "includes column AH" do
      expect(first_row[SpreadsheetMapperHelper.column_index("AH")].value).to eql(spreadsheet_presenter_1.start_business_case_date)
    end

    it "includes column AI" do
      expect(first_row[SpreadsheetMapperHelper.column_index("AI")].value).to eql(spreadsheet_presenter_1.complete_business_case_date)
    end

    it "includes column AJ" do
      expect(first_row[SpreadsheetMapperHelper.column_index("AJ")].value).to eql(spreadsheet_presenter_1.award_contract_date)
    end

    it "includes column AK" do
      expect(first_row[SpreadsheetMapperHelper.column_index("AK")].value).to eql(spreadsheet_presenter_1.start_construction_date)
    end

    it "includes column AL" do
      expect(first_row[SpreadsheetMapperHelper.column_index("AL")].value).to eql(spreadsheet_presenter_1.ready_for_service_date)
    end

    it "includes column BC" do
      expect(first_row[SpreadsheetMapperHelper.column_index("BC")].value).to be(0)
    end

    it "includes column BF" do
      expect(first_row[SpreadsheetMapperHelper.column_index("BF")].value).to be(0)
    end

    it "includes column BN" do
      expect(first_row[SpreadsheetMapperHelper.column_index("BN")].value).to be(0)
    end

    column_mapping = {
      MI: :hectares_of_intertidal_habitat_created_or_enhanced,
      MJ: :hectares_of_woodland_habitat_created_or_enhanced,
      MK: :hectares_of_wet_woodland_habitat_created_or_enhanced,
      ML: :hectares_of_wetland_or_wet_grassland_created_or_enhanced,
      MM: :hectares_of_grassland_habitat_created_or_enhanced,
      MN: :hectares_of_heathland_created_or_enhanced,
      MO: :hectares_of_pond_or_lake_habitat_created_or_enhanced,
      MP: :hectares_of_arable_land_lake_habitat_created_or_enhanced,
      MQ: :kilometres_of_watercourse_enhanced_or_created_comprehensive,
      MR: :kilometres_of_watercourse_enhanced_or_created_partial,
      MS: :kilometres_of_watercourse_enhanced_or_created_single,
      MT: :contains_natural_measures,
      MU: :main_natural_measure,
      MV: :natural_flood_risk_measures_cost,
      MW: :confidence_homes_better_protected,
      MX: :confidence_homes_by_gateway_four,
      MY: :confidence_homes_better_protected,
      MZ: :project_status,
      NA: :carbon_cost_build,
      NB: :carbon_cost_operation,
      NC: :last_updated,
      ND: :pso_name
    }

    column_mapping.each do |column, value|
      it "includes column #{column}" do
        expect(first_row[SpreadsheetMapperHelper.column_index(column)].value).to eql(spreadsheet_presenter_1.send(value))
      end
    end
  end
end
