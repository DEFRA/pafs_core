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

    it "includes column MR" do
      expect(first_row[SpreadsheetMapperHelper.column_index("MR")].value).to eql(spreadsheet_presenter_1.designated_site)
    end

    it "includes MS" do
      expect(first_row[SpreadsheetMapperHelper.column_index("MS")].value).to eql(spreadsheet_presenter_1.improve_surface_or_groundwater_amount)
    end

    it "includes column MT" do
      expect(first_row[SpreadsheetMapperHelper.column_index("MT")].value).to eql(spreadsheet_presenter_1.remove_fish_or_eel_barrier)
    end

    it "includes column MU" do
      expect(first_row[SpreadsheetMapperHelper.column_index("MTU")].value).to eql(spreadsheet_presenter_1.fish_or_eel_amount)
    end

    it "includes column MV" do
      expect(first_row[SpreadsheetMapperHelper.column_index("MV")].value).to eql(spreadsheet_presenter_1.improve_river_amount)
    end

    it "includes column MW" do
      expect(first_row[SpreadsheetMapperHelper.column_index("MW")].value).to eql(spreadsheet_presenter_1.improve_habitat_amount)
    end

    it "includes column MX" do
      expect(first_row[SpreadsheetMapperHelper.column_index("MX")].value).to eql(spreadsheet_presenter_1.create_habitat_amount)
    end

    it "includes column NB" do
      expect(first_row[SpreadsheetMapperHelper.column_index("NB")].value.to_s).to eql(spreadsheet_presenter_1.state.state.capitalize)
    end

    it "includes the last_updated column" do
      expect(first_row[SpreadsheetMapperHelper.column_index("NE")].value.to_s).to eq(spreadsheet_presenter_1.last_updated)
    end

    it "includes the pso_name column" do
      expect(first_row[SpreadsheetMapperHelper.column_index("NF")].value.to_s).to eq(spreadsheet_presenter_1.pso_name)
    end
  end
end
