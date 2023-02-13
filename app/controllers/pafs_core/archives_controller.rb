# frozen_string_literal: true

module PafsCore
  class ArchivesController < PafsCore::ApplicationController
    def index
      page = params.fetch(:page, 1)
      projects_per_page = params.fetch(:per, 10)
      @projects = navigator.archived(params).page(page).per(projects_per_page)
    end

    private

    def navigator
      @navigator ||= PafsCore::ProjectNavigator.new current_resource
    end
  end
end
