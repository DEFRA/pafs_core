# frozen_string_literal: true
require "rubyXL"
require "csv"

module PafsCore
  class SpreadsheetService
    include PafsCore::Fcerm1

    def generate_xlsx(project)
      workbook = read_fcerm1_template
      # until sheet names are fixed, take the first sheet in the workbook
      sheet = workbook.worksheets[0]

      fix_worksheet(sheet)

      add_project_to_sheet(sheet, PafsCore::SpreadsheetPresenter.new(project),
                           FIRST_DATA_ROW)
      workbook
    end

    def generate_multi_xlsx(projects)
      workbook = read_fcerm1_template
      # until sheet names are fixed, take the first sheet in the workbook
      sheet = workbook.worksheets[0]

      fix_worksheet(sheet)

      row_number = FIRST_DATA_ROW
      projects.each do |project|
        add_project_to_sheet(
          sheet,
          PafsCore::SpreadsheetPresenter.new(project),
          row_number
        )
        row_number += 1
      end
      workbook
    end

    def generate_csv(project)
      CSV.generate do |csv|
        csv << %w[ not yet implemented ]
      end
    end

  private
    def read_fcerm1_template
      RubyXL::Parser.parse(PafsCore::Engine.root.join("lib", "fcerm1_template.xlsx"))
    end

    def fix_worksheet(sheet)
      # HACK: for some reason the formula in column BJ (index 61) is not recognised by RubyXL
      #       so we'll poke in the correct formula here
      sheet[FIRST_DATA_ROW][61].change_contents(0, "JO#{FIRST_DATA_ROW + 1}")
    end

    def copy_previous_row(sheet, row_no)
      sheet.insert_row(row_no)
      new_row = sheet[row_no]
      prev_row = sheet[row_no - 1]

      prev_row.cells.each_with_index do |cell, i|
        if cell.formula
          # formulas need to be updated for the new row_no
          # the row number reference in the formulas are "1" based not "0" based
          new_row[i].change_contents(0, cell.formula.expression.gsub(/#{row_no}/, (row_no + 1).to_s))
        elsif cell.value
          new_row[i].change_contents(cell.value)
        end
      end
    end

    def add_project_to_sheet(sheet, project, row_no)
      # multi project spreadsheets need additional rows to work with
      copy_previous_row(sheet, row_no) if row_no != FIRST_DATA_ROW
      # sheet.insert_row(row_no) if row_no != FIRST_DATA_ROW

      FCERM1_COLUMN_MAP.each do |col|
        if col.fetch(:export, true)
          range = col.fetch(:date_range, false)
          name = col[:field_name]
          conditional_proc = col.fetch(:if, nil)
          use_value = conditional_proc.nil? || conditional_proc.call(project)

          if range
            start_column = column_index(col[:column])
            years = [-1].concat((2015..2027).to_a)
            years.each_with_index do |year, i|
              value = use_value ? project.send(name, year) : 0
              sheet[row_no][start_column + i].change_contents(value)
            end
          else
            value = use_value ? project.send(col[:field_name]) : 0
            sheet[row_no][column_index(col[:column])].change_contents(value)
          end
        end
      end
    end
  end
end
