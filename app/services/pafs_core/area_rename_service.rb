# frozen_string_literal: true

module PafsCore
  class AreaRenameService

    def initialize(area_type, area_name)
      @area_type = area_type
      @area_name = area_name
    end

    def run(new_name)
      raise StandardError, "Area \"#{@area_name}\" of type #{@area_type} not found" unless area

      area.update_attribute(:name, new_name)
    end

    private

    def area
      @area ||= PafsCore::Area.where(name: @area_name, area_type: @area_type).first
    end
  end
end
