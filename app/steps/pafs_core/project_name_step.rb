# frozen_string_literal: true

module PafsCore
  class ProjectNameStep < BasicStep
    delegate :name, :name=, to: :project

    validates :name, presence: { message: "Tell us the project name" }

    validates :name, format: {
      with: /\A[A-Za-z0-9 _-]+\z/,
      message: "The project name must only contain letters, underscores, hyphens and numbers"
    }

    validate :name_must_be_unique

    private

    def step_params(params)
      params.require(:project_name_step).permit(:name)
    end

    # BasicStep does not have access to the uniqueness validator presumably
    # because it's not an ActiveRecord model. So we need to implement our own
    def name_must_be_unique
      if PafsCore::Project.exists?(name: name)
        errors.add(:name, "The project name already exists. Your project must have a unique name.")
      end
    end
  end
end
