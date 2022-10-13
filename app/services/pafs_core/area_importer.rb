# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class AreaImporter

    require "csv"
    HEADERS = ["name",
               "parent area",
               "type",
               "sub type"].freeze

    def initialize
      @areas_to_be_imported = []
      @faulty_entries = []
    end

    def import(path_to_file)
      abort("Areas already exist") if PafsCore::Area.count.positive?

      extract_csv_data(path_to_file)

      import_areas
    end

    def import_new_areas(path_to_folder)
      new_areas_csvs = Dir["#{path_to_folder}/*.csv"]

      new_areas_csvs.each { |area_csv| extract_csv_data(area_csv) }

      import_areas
    end

    private

    def extract_csv_data(path_to_file)
      CSV.foreach(path_to_file, headers: true) { |row| @areas_to_be_imported << row.to_h }
    end

    def import_areas
      abort("Headers incorrect.") unless (@areas_to_be_imported.first.keys - HEADERS).empty?

      remove_areas_that_have_already_been_imported

      areas = group_by_type(@areas_to_be_imported)
      PafsCore::Area::AREA_TYPES.each { |area_type| create_records(areas[area_type]) unless areas[area_type].nil? }
      output_errors_to_console(@faulty_entries) unless @faulty_entries.empty?
    end

    def remove_areas_that_have_already_been_imported
      existing_areas = PafsCore::Area.pluck(:name, :area_type)

      @areas_to_be_imported.delete_if { |area| existing_areas.include? [area[:name], area[:area_type]] }
    end

    def group_by_type(areas)
      areas.group_by { |area| area["type"] }
    end

    def create_records(areas)
      areas_grouped_by_parent = group_by_parent(areas)
      create_child_records(areas_grouped_by_parent)
    end

    def group_by_parent(areas)
      areas.group_by { |area| area["parent area"] }
    end

    def create_child_records(areas_grouped_by_parent)
      areas_grouped_by_parent.each do |parent, children|
        parent = Area.find_by_name(parent)

        children.each do |child|
          area = {
            name: child["name"],
            area_type: child["type"],
            sub_type: child["sub type"]
          }
          area[:parent_id] = parent.id if parent

          if parent || child["type"] == PafsCore::Area::AREA_TYPES[0]
            begin
              a = Area.new(area)
              a.save!
            rescue StandardError => e
              report_error(e.message, child)
            end
          else
            report_error("No matching parent area found", child)
          end
        end
      end
    end

    def output_errors_to_console(faulty_entries)
      puts faulty_entries unless Rails.env.test?
    end

    def report_error(error, record)
      record[:error] = error
      @faulty_entries << record
    end
  end
end
