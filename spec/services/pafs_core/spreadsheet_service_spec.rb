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

    it "includes column BI" do
      expect(first_row[SpreadsheetMapperHelper.column_index("BI")].value).to be(0)
    end

    it "includes column BL" do
      expect(first_row[SpreadsheetMapperHelper.column_index("BL")].value).to be(0)
    end

    it "includes column BM" do
      expect(first_row[SpreadsheetMapperHelper.column_index("BM")].value).to be(0)
    end

    it "includes column GT" do
      expect(first_row[SpreadsheetMapperHelper.column_index("GT")].value).to eql(spreadsheet_presenter_1.designated_site)
    end

    it "includes GU" do
      expect(first_row[SpreadsheetMapperHelper.column_index("GU")].value).to eql(spreadsheet_presenter_1.improve_surface_or_groundwater_amount)
    end

    it "includes column GV" do
      expect(first_row[SpreadsheetMapperHelper.column_index("GV")].value).to eql(spreadsheet_presenter_1.remove_fish_or_eel_barrier)
    end

    it "includes column GW" do
      expect(first_row[SpreadsheetMapperHelper.column_index("GW")].value).to eql(spreadsheet_presenter_1.fish_or_eel_amount)
    end

    it "includes column GX" do
      expect(first_row[SpreadsheetMapperHelper.column_index("GX")].value).to eql(spreadsheet_presenter_1.improve_river_amount)
    end

    it "includes column GY" do
      expect(first_row[SpreadsheetMapperHelper.column_index("GY")].value).to eql(spreadsheet_presenter_1.improve_habitat_amount)
    end

    it "includes column GZ" do
      expect(first_row[SpreadsheetMapperHelper.column_index("GZ")].value).to eql(spreadsheet_presenter_1.create_habitat_amount)
    end

    it "includes column HL" do
      expect(first_row[SpreadsheetMapperHelper.column_index("HL")].value.to_s).to eql(spreadsheet_presenter_1.state.state.capitalize)
    end

    it "includes the last_updated column" do
      expect(first_row[SpreadsheetMapperHelper.column_index("HO")].value.to_s).to eq(spreadsheet_presenter_1.last_updated)
    end

    it "includes the pso_name column" do
      expect(first_row[SpreadsheetMapperHelper.column_index("HP")].value.to_s).to eq(spreadsheet_presenter_1.pso_name)
    end
  end
end
