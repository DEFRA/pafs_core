# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  module ProjectsHelper
    def financial_year_end
      now = Date.today
      Date.new(now.month < 4 ? now.year : now.year + 1, 3, 31)
    end

    def six_year_limit_date
      (financial_year_end + 6.years).to_formatted_s(:long_ordinal)
    end

    def project_step_path(project)
      pafs_core.project_step_path(id: project.to_param, step: project.step)
    end

    def nav_step_item(project, step)
      project_step = PafsCore::ProjectNavigator.build_project_step(project.project, step)
      content_tag(:li) do
        concat(content_tag(:span, class: "complete-flag") do
          icon("check") if project_step.completed?
        end)
        if project_step.disabled?
          concat(content_tag(:span, class: "inactive") do
            step_label(step)
          end)
        elsif project.step_name == project_step.step_name
          concat(content_tag(:span, class: "selected") do
            step_label(step)
          end)
        else
          concat link_to step_label(step), project_step_path(project_step)
        end
      end
    end

    def step_label(step)
      t("#{step}_step_label")
    end

    def key_month_field(f, attr)
      content_tag(:div, class: "form-group form-group-month") do
        concat(f.label(attr, t(".month_label"), class: "form-label"))
        concat(f.number_field(attr, in: 1..12, class: "form-control form-month"))
      end
    end

    def key_year_field(f, attr)
      content_tag(:div, class: "form-group form-group-year") do
        concat(f.label(attr, t(".year_label"), class: "form-label"))
        concat(f.number_field(attr, in: 2000...2100, class: "form-control form-year"))
      end
    end
  end
end
