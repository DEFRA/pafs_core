# frozen_string_literal: true

module PafsCore
  class ProjectNavigator
    attr_reader :user

    def initialize(user)
      # when instantiated from a controller the 'current_user' should
      # be passed in. This will allow us to audit actions etc. down the line.
      @user = user
    end

    def first_step
      sequence.first
    end

    def next_step(step, project)
      step = sequence.next(step, project)
      return :summary if step.to_s.starts_with? "summary_"

      step
    end

    def next_step_raw(step, project)
      sequence.next(step, project)
    end

    def last_step
      sequence.last
    end

    def new_blank_project(attrs = {})
      PafsCore::Project.new(attrs)
    end

    def start_new_project(attrs = {})
      # we will need to position a project so that it 'belongs' somewhere
      # and is 'owned' by a user.  I envisage that we would use the
      # current_user passed into the constructor to get this information.
      project = project_service.create_project(attrs)
      Object.const_get("PafsCore::#{sequence.first.to_s.camelcase}Step").new project
    end

    def find(ref_number)
      project_service.find_project(ref_number)
    end

    def find_apt_projects
      project_service.downloadable_projects
    end

    def archived(options = {})
      options[:state] = "archived"
      project_service.search(options)
    end

    def search(options = {})
      options[:state] = "submitted" if user.primary_area.ea_area?
      project_service.search(options)
    end

    def find_project_step(id, step)
      check_step(step.to_sym)
      # retrieve and wrap project
      build_project_step(project_service.find_project(id), step, user)
    end

    def build_project_step(project, step, user)
      # accept a step or a raw project activerecord object
      project = project.project if project.respond_to? :project
      # TODO: check that this user has permission to access this project
      Object.const_get("PafsCore::#{step.to_s.camelcase}Step").new(project, user)
    end

    def step_anchor(step)
      step_anchors.find { |s| !s[step].nil? }
    end

    private

    def step_anchors
      @anchor_steps ||= define_step_anchors
    end

    def define_step_anchors
      [
        { summary_1:  :project_name },
        { summary_2:  :project_type },
        { summary_3:  :financial_year },
        { summary_4:  :location },
        { summary_5:  :key_dates },
        { summary_6:  :funding_sources },
        { summary_7:  :earliest_start },
        { summary_8:  :risks },
        { summary_9:  :standard_of_protection },
        { summary_91: :standard_of_protection },
        { summary_10: :approach },
        { summary_11: :environmental_outcomes },
        { summary_12: :natural_flood_risk_measure_included },
        { summary_13: :urgency },
        { summary_14: :funding_calculator },
        { summary_15: :confidence },
        { summary_16: :carbon }
      ]
    end

    def sequence
      @sequence ||= define_sequence
    end

    # rubocop:disable Metrics/AbcSize
    def define_sequence
      Dibble.sequence do |s|
        s.add :project_name
        s.add :summary_1
        s.add :project_type
        s.add :summary_2
        s.add :financial_year
        s.add :financial_year_alternative, unless: ->(p) { p.step == :financial_year }
        s.add :summary_3

        s.add :location
        s.add :benefit_area_file, unless: ->(p) { p.benefit_area_file_name.present? }
        s.add :benefit_area_file_summary
        # s.add :map, unless: ->(p) { p.benefit_area_file_name.present? }
        # s.add :benefit_area_file_summary, if: ->(p) { p.benefit_area_file_name.present? }
        s.add :summary_4

        s.add :start_outline_business_case_date
        s.add :award_contract_date
        s.add :start_construction_date
        s.add :ready_for_service_date
        s.add :summary_5

        s.add :funding_sources

        s.add :public_contributors, if: ->(p) { p.project.public_contributions? }
        s.add :public_contributor_values, if: ->(p) { p.project.public_contributions? }

        s.add :private_contributors, if: ->(p) { p.project.private_contributions? }
        s.add :private_contributor_values, if: ->(p) { p.project.private_contributions? }

        s.add :other_ea_contributors, if: ->(p) { p.project.other_ea_contributions? }
        s.add :other_ea_contributor_values, if: ->(p) { p.project.other_ea_contributions? }

        s.add :funding_values

        s.add :funding_values_summary, if: :javascript_disabled?
        s.add :summary_6

        s.add :earliest_start
        s.add :earliest_date, if: :could_start_early?
        s.add :summary_7

        s.add :risks
        s.add :main_risk,
              if: ->(p) { p.selected_risks.count > 1 }
        s.add :flood_protection_outcomes,
              if: ->(p) { p.protects_against_flooding? }
        s.add :flood_protection_outcomes_summary,
              if: ->(p) { p.protects_against_flooding? && p.javascript_disabled? }
        s.add :coastal_erosion_protection_outcomes,
              if: ->(p) { p.protects_against_coastal_erosion? }
        s.add :coastal_erosion_protection_outcomes_summary,
              if: ->(p) { p.protects_against_coastal_erosion? && p.javascript_disabled? }
        s.add :summary_8

        s.add :standard_of_protection, if: :protects_against_flooding?
        s.add :standard_of_protection_after
        s.add :summary_91,
              unless: lambda { |p|
                p.protects_against_coastal_erosion? &&
                  (p.coastal_protection_before.nil? || p.coastal_protection_after.nil?)
              }
        s.add :standard_of_protection_coastal, if: :protects_against_coastal_erosion?
        s.add :standard_of_protection_coastal_after
        s.add :summary_9

        s.add :approach
        s.add :summary_10

        s.add :any_environmental_benefits
        s.add :intertidal_habitat_created_or_enhanced
        s.add :hectares_of_intertidal_habitat_created_or_enhanced
        s.add :woodland_habitat_created_or_enhanced
        s.add :hectares_of_woodland_habitat_created_or_enhanced
        s.add :wet_woodland_habitat_created_or_enhanced
        s.add :hectares_of_wet_woodland_habitat_created_or_enhanced
        s.add :wetland_or_wet_grassland_habitat_created_or_enhanced
        s.add :hectares_of_wetland_or_wet_grassland_habitat_created_or_enhanced
        s.add :grassland_habitat_created_or_enhanced
        s.add :hectares_of_grassland_habitat_created_or_enhanced
        s.add :heathland_habitat_created_or_enhanced
        s.add :hectares_of_heathland_created_or_enhanced
        s.add :ponds_lakes_habitat_created_or_enhanced
        s.add :hectares_of_pond_or_lake_habitat_created_or_enhanced
        s.add :arable_land_created_or_enhanced
        s.add :hectares_of_arable_land_lake_habitat_created_or_enhanced
        s.add :comprehensive_restoration
        s.add :kilometres_of_watercourse_enhanced_or_created_comprehensive
        s.add :partial_restoration
        s.add :kilometres_of_watercourse_enhanced_or_created_partial
        s.add :create_habitat_watercourse
        s.add :kilometres_of_watercourse_enhanced_or_created_single
        s.add :summary_11

        s.add :natural_flood_risk_measures_included
        s.add :natural_flood_risk_measures, if: :natural_flood_risk_measures_included?
        s.add :natural_flood_risk_measures_cost, if: :natural_flood_risk_measures_included?
        s.add :summary_12

        s.add :urgency
        s.add :urgency_details, if: :urgent?
        s.add :summary_13

        s.add :funding_calculator, unless: ->(p) { p.funding_calculator_file_name.present? }
        s.add :funding_calculator_summary
        s.add :summary_14

        s.add :confidence_homes_better_protected
        s.add :confidence_homes_by_gateway_four
        s.add :confidence_secured_partnership_funding
        s.add :summary_15

        s.add :carbon_cost_build
        s.add :carbon_cost_operation
        s.add :summary_16
      end
    end
    # rubocop:enable Metrics/AbcSize

    def check_step(step)
      raise ActiveRecord::RecordNotFound, "Unknown step [#{step}]" unless sequence.include? step.to_sym
    end

    def project_service
      @project_service ||= ProjectService.new(user)
    end
  end
end
