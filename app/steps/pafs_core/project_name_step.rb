# frozen_string_literal: true

module PafsCore
  class ProjectNameStep < BasicStep
    delegate :name, :name=, to: :project

    validates :name, presence: { message: "Tell us the project name" }

    validates :name, format: {
      with: /\A[A-Za-z0-9 _-]+\z/,
      message: "The project name must only contain letters, underscores, hyphens and numbers"
    }

    private

    def step_params(params)
      params.require(:project_name_step).permit(:name)
    end
  end
end
