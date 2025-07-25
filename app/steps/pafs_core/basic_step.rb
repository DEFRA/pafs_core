# frozen_string_literal: true

module PafsCore
  class BasicStep
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Model

    attr_reader :project, :user, :javascript_enabled
    alias javascript_enabled? javascript_enabled

    delegate  :id,
              :reference_number,
              :to_param,
              :persisted?,
              to: :project

    # this validation allows us to ensure the record is valid
    validates :reference_number, presence: true

    def initialize(model, user = nil)
      @project = model
      @user = user
      @javascript_enabled = false
    end

    def update(params)
      @javascript_enabled = params.fetch(:js_enabled, false)
      assign_attributes(step_params(params))
      project.updated_by = user if project.respond_to?(:updated_by)
      valid? && project.save
    end

    def save!(*)
      return project.save! if valid?

      raise ActiveRecord::RecordInvalid, self
    end

    # override this in the subclass if you need more functionality
    def completed?
      valid?
    end

    def incomplete?
      !completed?
    end

    # def javascript_enabled?
    #   @javascript_enabled
    # end

    def javascript_disabled?
      !javascript_enabled?
    end

    # override this in the subclass if the step could conditionally be disabled
    def disabled?
      false
    end

    def step_name
      self.class.name.demodulize.chomp("Step").underscore
    end

    def step
      step_name.to_sym
    end

    # override this to handle any setup required before being viewed
    # This is called before rendering in the controller
    def before_view(params); end

    def view_path
      "pafs_core/projects/steps/#{step}"
    end

    def previous_step
      navigator.previous_step(step, project)
    end

    private

    def navigator
      @navigator ||= PafsCore::ProjectNavigator.new(user)
    end
  end
end
