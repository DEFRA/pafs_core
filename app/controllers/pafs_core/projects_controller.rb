# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
class PafsCore::ProjectsController < PafsCore::ApplicationController
  # NOTE: this should be added via a decorator in consuming qpp if needed
  # before_action :authenticate_user!

  def index
    # dashboard page
    # (filterable) list of projects
    @projects = navigator.search(params)
  end

  def show
    # project summary page
    @project = PafsCore::ProjectSummaryPresenter.new navigator.find(params[:id])
  end

  # def new
  #   # start a new project by asking whether GiA funding is required before 31 March 2021
  #   @project = navigator.new_blank_project
  # end
  #
  # # POST
  # def funding
  #   # this is 'new' part 2
  #   # continue initialising a project by asking whether Local Levy is required before 31 March 2021
  #   @project = navigator.new_blank_project(project_params)
  #   if @project.fcerm_gia.nil?
  #     @project.errors.add(:fcerm_gia, "^Tell us if you need Grant in Aid funding before 31 March 2021")
  #     render :new
  #   end
  # end
  #
  # # POST
  # def create
  #   # if the project starts within the next 6 years
  #   # save the new project and start the steps
  #   @project = navigator.new_blank_project(project_params)
  #
  #   if !@project.fcerm_gia.nil? && !@project.local_levy.nil?
  #     if @project.fcerm_gia? || @project.local_levy?
  #       # create project
  #       @project = navigator.start_new_project(project_params)
  #       redirect_to reference_number_project_path(@project)
  #     else
  #       # not a project we want to know about (yet)
  #       redirect_to pipeline_projects_path
  #     end
  #   elsif @project.fcerm_gia.nil?
  #     @project = navigator.new_blank_project(project_params)
  #     @project.errors.add(:fcerm_gia, "^Tell us if you need Grant in Aid funding before 31 March 2021")
  #     render :new
  #   elsif @project.local_levy.nil?
  #     @project = navigator.new_blank_project(project_params)
  #     @project.errors.add(:local_levy, "^Tell us if you need local levy funding before 31 March 2021")
  #     render :funding
  #   end
  # end
  #
  # GET
  def pipeline
  end

  # GET
  def reference_number
    @project = navigator.find_project_step(params[:id], PafsCore::ProjectNavigator.first_step)
  end

  # GET
  def step
    # edit step
    @project = navigator.find_project_step(params[:id], params[:step])
    # we want to go to the page in the process requested in the
    # params[:step] part of the URL and display the appropriate form
    if @project.disabled?
      raise_not_found
    else
      # give the step the opportunity to do any tasks prior to being viewed
      @project.before_view
      # render the step
      render @project.view_path
    end
  end

  # PATCH
  def save
    # submit data for the current step and continue or exit
    # if request is exit redirect to summary or dashboard?
    # else go to next step
    @project = navigator.find_project_step(params[:id], params[:step])
    # each step is responsible for managing their params safely
    if @project.update(params)
      next_step = navigator.next_step(@project.step, @project)
      if next_step == :summary
        # we're at the end so return to project summary
        redirect_to project_path(id: @project.to_param)
      else
        redirect_to project_step_path(id: @project.to_param, step: next_step)
      end
    else
      # NOTE: not calling @project.before_view, but we could if we need to
      render @project.view_path
    end
  end

  # GET
  def download_funding_calculator
    @project = navigator.find_project_step(params[:id], :funding_calculator)
    @project.download do |data, filename, content_type|
      send_data(data, filename: filename, type: content_type)
    end
  end

  # GET
  def delete_funding_calculator
    @project = navigator.find_project_step(params[:id], :funding_calculator)
    @project.delete_calculator
    redirect_to project_step_path(id: @project.to_param, step: :funding_calculator)
  end

private
  def project_params
    params.require(:project).permit(:fcerm_gia, :local_levy)
  end

  def navigator
    @navigator ||= PafsCore::ProjectNavigator.new current_resource
  end
end
