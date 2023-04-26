# frozen_string_literal: true

module PafsCore
  class ChangeProjectAreaService

    def initialize(project)
      @project = project
    end

    def run(new_area)
      return if @project.owner == new_area

      previous_owning_area = @project.owner
      previous_owning_area_project = PafsCore::AreaProject.where(project_id: @project.id,
                                                                 area_id: previous_owning_area, owner: true).first

      ActiveRecord::Base.transaction do
        new_owning_area_project = PafsCore::AreaProject.where(project_id: @project.id, area_id: new_area.id).first ||
                                  PafsCore::AreaProject.create!(project_id: @project.id, area_id: new_area.id)
        new_owning_area_project.update(owner: true)
        previous_owning_area_project&.destroy!

        # The RMA name is also stored directly on the project
        @project.update(rma_name: new_area.name)
      end

      true
    rescue StandardError => e
      message = "Error changing area for project #{@project.reference_number}"
      Rails.logger.error "#{message}: #{e}"
      Airbrake.notify(e, message: message)
      false
    end
  end
end
