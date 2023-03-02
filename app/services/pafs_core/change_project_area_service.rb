# frozen_string_literal: true

module PafsCore
  class ChangeProjectAreaService

    def initialize(project_number)
      @project = Project.find_by(reference_number: project_number)
      raise StandardError, "Project not found: #{project_number}" if @project.blank?
    end

    def run(new_area_name)
      new_area = Area.find_by(name: new_area_name)
      current_area = @project.areas.first
      return if current_area == new_area

      @project.areas.delete(current_area) unless current_area.nil?
      @project.areas << new_area
      @project.save!
    end
  end
end
