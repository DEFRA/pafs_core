# frozen_string_literal: true

require "rubyXL"
require "rubyXL/convenience_methods/cell"
require "rubyXL/convenience_methods/worksheet"

require "csv"

module PafsCore
  class SpreadsheetService
    include PafsCore::Fcerm1

    def generate_xlsx(project)
      workbook = read_fcerm1_template
      # until sheet names are fixed, take the first sheet in the workbook
      sheet = workbook.worksheets[0]

      # LB - I don't think this fix_worksheet is needed anymore, but I'm leaving commented out code here
      # till that gets fully tested and confirmed
      # @TODO - remove this code once confirmed
      # fix_worksheet(sheet)

      add_project_to_sheet(sheet, PafsCore::SpreadsheetPresenter.new(project),
                           FIRST_DATA_ROW)

      PafsCore::Spreadsheet::Contributors::Export.new(workbook, project).generate
      workbook
    end

    def generate_multi_xlsx(projects)
      workbook = read_fcerm1_template
      # until sheet names are fixed, take the first sheet in the workbook
      sheet = workbook.worksheets[0]

      # LB - I don't think this fix_worksheet is needed anymore, but I'm leaving commented out code here
      # till that gets fully tested and confirmed
      # @TODO - remove this code once confirmed
      # fix_worksheet(sheet)

      row_number = FIRST_DATA_ROW
      total_projects = projects.size
      current_project = nil
      projects.find_each.with_index do |project, project_index|
        current_project = project
        add_project_to_sheet(
          sheet,
          PafsCore::SpreadsheetPresenter.new(project),
          row_number
        )

        PafsCore::Spreadsheet::Contributors::Export.new(workbook, project).generate

        yield(total_projects, project_index) if block_given?
        row_number += 1
      rescue StandardError => e
        Rails.logger.error "Download failed for project #{current_project.reference_number}: #{e.inspect}"
        Airbrake.notify(e)
        # re-raise the error so the UI reports the issue to the user
        raise e
      end
      workbook
    rescue StandardError => e
      Rails.logger.error "Error generating multi_xlsx: #{e.inspect}"
      Airbrake.notify(e, message: "Error generating multi_xlsx")
    end

    def generate_csv(_project)
      CSV.generate do |csv|
        csv << %w[not yet implemented]
      end
    end

    private

    def read_fcerm1_template
      RubyXL::Parser.parse(PafsCore::Engine.root.join("lib", "fcerm1_template.xlsx"))
    end

    def fix_worksheet(sheet)
      # HACK: for some reason the formula in column BH-BT are not recognised by RubyXL
      #       so we'll poke in the correct formula here
      formulae_map = [
        { BN: ["MK"] },
        { BO: ["ML"] },
        { BP: ["MM"] }
      ]
      formulae_map.each do |formula_hash|
        column = formula_hash.keys.first.to_s
        cells = formula_hash.values.first.collect { |cell| "#{cell}#{FIRST_DATA_ROW + 1}" }.join("+")
        sheet[FIRST_DATA_ROW][column_index(column)].change_contents(0, cells)
      end
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
          if cell.value.is_a?(Float) && cell.value.nan?
            new_row[i].change_contents(0)
          else
            new_row[i].change_contents(cell.value)
          end
        end
      end
    end

    def add_project_to_sheet(sheet, project, row_no)
      # multi project spreadsheets need additional rows to work with
      copy_previous_row(sheet, row_no) if row_no != FIRST_DATA_ROW

      FCERM1_COLUMN_MAP.each do |col|
        next unless col.fetch(:export, true)

        range = col.fetch(:date_range, false)
        name = col[:field_name]
        conditional_proc = col.fetch(:if, nil)
        use_value = conditional_proc.nil? || conditional_proc.call(project)

        if range
          start_column = column_index(col[:column])
          years = (2023..2032).to_a
          years.each_with_index do |year, i|
            value = use_value ? project.send(name, year) : 0
            sheet[row_no][start_column + i].change_contents(value)
          end
        else
          begin
            value = use_value ? project.send(col[:field_name]) : 0
            sheet[row_no][column_index(col[:column])].change_contents(value)
          rescue StandardError => e
            raise "Boom - Project (#{project.slug}) Row no (#{row_no}) col (#{col}) " \
                  "field_name (#{col[:field_name]}) value (#{value}): exception #{e}"
          end
        end
      end
    end
  end
end
