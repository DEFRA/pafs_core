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
      it "includes column #{column} and shows correct value" do
        expect(first_row[SpreadsheetMapperHelper.column_index(column)].value).to eql(spreadsheet_presenter_1.send(value))
      end
    end

    formula_mapping = {
      BO: "BY7+CI7+CS7+DC7+DM7+DW7+EG7+EQ7+FA7+FK7+FU7+GE7+GO7+GY7",
      BP: "BZ7+CJ7+CT7+DD7+DN7+DX7+EH7+ER7+FB7+FL7+FV7+GF7+GP7+GZ7",
      BQ: "CA7+CK7+CU7+DE7+DO7+DY7+EI7+ES7+FC7+FM7+FW7+GG7+GQ7+HA7",
      BR: "CB7+CL7+CV7+DF7+DP7+DZ7+EJ7+ET7+FD7+FN7+FX7+GH7+GR7+HB7",
      BS: "CC7+CM7+CW7+DG7+DQ7+EA7+EK7+EU7+FE7+FO7+FY7+GI7+GS7+HC7",
      BT: "CD7+CN7+CX7+DH7+DR7+EB7+EL7+EV7+FF7+FP7+FZ7+GJ7+GT7+HD7",
      BU: "CE7+CO7+CY7+DI7+DS7+EC7+EM7+EW7+FG7+FQ7+GA7+GK7+GU7+HE7",
      BV: "CF7+CP7+CZ7+DJ7+DT7+ED7+EN7+EX7+FH7+FR7+GB7+GL7+GV7+HF7",
      BW: "CG7+CQ7+DA7+DK7+DU7+EE7+EO7+EY7+FI7+FS7+GC7+GM7+GW7+HG7",
      BX: "CH7+CR7+DB7+DL7+DV7+EF7+EP7+EZ7+FJ7+FT7+GD7+GN7+GX7+HH7",
      AM: "BO7+BP7+BQ7+BR7+BS7+BT7+BU7+BV7+BW7+BX7",
      AN: "BY7+BZ7+CA7+CB7+CC7+CD7+CE7+CF7+CG7+CH7",
      AO: "CI7+CJ7+CK7+CL7+CM7+CN7+CO7+CP7+CQ7+CR7",
      AP: "CS7+CT7+CU7+CV7+CW7+CX7+CY7+CZ7+DA7+DB7",
      AQ: "DC7+DD7+DE7+DF7+DG7+DH7+DI7+DJ7+DK7+DL7",
      AR: "DM7+DN7+DO7+DP7+DQ7+DR7+DS7+DT7+DU7+DV7",
      AS: "DW7+DX7+DY7+DZ7+EA7+EB7+EC7+ED7+EE7+EF7",
      AT: "EG7+EH7+EI7+EJ7+EK7+EL7+EM7+EN7+EO7+EP7",
      AU: "EQ7+ER7+ES7+ET7+EU7+EV7+EW7+EX7+EY7+EZ7",
      AV: "FA7+FB7+FC7+FD7+FE7+FF7+FG7+FH7+FI7+FJ7",
      AW: "FK7+FL7+FM7+FN7+FO7+FP7+FQ7+FR7+FS7+FT7",
      AX: "FU7+FV7+FW7+FX7+FY7+FZ7+GA7+GB7+GC7+GD7",
      AY: "GE7+GF7+GG7+GH7+GI7+GJ7+GK7+GL7+GM7+GN7",
      AZ: "GO7+GP7+GQ7+GR7+GS7+GT7+GU7+GV7+GW7+GX7",
      BA: "GY7+GZ7+HA7+HB7+HC7+HD7+HE7+HF7+HG7+HH7",
      BB: "HI7+HJ7+HK7+HL7+HM7+HN7+HO7+HP7+HQ7+HR7",
      BC: "HS7+HT7+HU7+HV7+HW7+HX7+HY7+HZ7+IA7+IB7",
      BD: "IC7+ID7+IE7+IF7+IG7+IH7+II7+IJ7+IK7+IL7",
      BE: "IM7+IN7+IO7+IP7+IQ7+IR7+IS7+IT7+IU7+IV7",
      BF: "IW7+IX7+IY7+IZ7+JA7+JB7+JC7+JD7+JE7+JF7",
      BG: "JG7+JH7+JI7+JJ7+JK7+JL7+JM7+JN7+JO7+JP7",
      BH: "JQ7+JR7+JS7+JT7+JU7+JV7+JW7+JX7+JY7+JZ7",
      BI: "KA7+KB7+KC7+KD7+KE7+KF7+KG7+KH7+KI7+KJ7",
      BJ: "KK7+KL7+KM7+KN7+KO7+KP7+KQ7+KR7+KS7+KT7",
      BK: "KU7+KV7+KW7+KX7+KY7+KZ7+LA7+LB7+LC7+LD7",
      BL: "LE7+LF7+LG7+LH7+LI7+LJ7+LK7+LL7+LM7+LN7",
      BM: "LO7+LP7+LQ7+LR7+LS7+LT7+LU7+LV7+LW7+LX7",
      BN: "LY7+LZ7+MA7+MB7+MC7+MD7+ME7+MF7+MG7+MH7"
    }

    formula_mapping.each do |column, formula|
      it "includes column #{column} with correct formula" do
        expect(first_row[SpreadsheetMapperHelper.column_index(column)].formula.expression).to eql(formula)
      end
    end
  end
end
