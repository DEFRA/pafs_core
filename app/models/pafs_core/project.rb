# frozen_string_literal: true

require "bstard"

module PafsCore
  class Project < ApplicationRecord
    include PafsCore::DateUtils
    validates :reference_number, presence: true, uniqueness: { scope: :version }
    # broaden validation to cope with initial bulk import of existing projects
    # with subtly non-standard formatting
    # rubocop:disable Layout/LineLength
    validates :reference_number,
              format: { with: %r{\A(AC|AE|AN|NO|NW|SN|SO|SW|TH|TR|TS|WX|YO)[A-Z]\d{3,4}[A-Z]?/\d{2,3}[A-Z]?/\d{2,4}[A-Z]{1,2}\z},
                        message: "has an invalid format" }
    # rubocop:enable Layout/LineLength

    validates :version, presence: true

    belongs_to :creator, class_name: "User", optional: true
    belongs_to :updated_by, polymorphic: true, optional: true
    has_many :area_projects, dependent: :destroy
    has_many :areas, through: :area_projects
    has_many :funding_values, dependent: :destroy
    has_many :funding_contributors, through: :funding_values
    has_many :flood_protection_outcomes, dependent: :destroy
    has_many :flood_protection2040_outcomes, class_name: "::PafsCore::FloodProtection2040Outcome", dependent: :destroy
    has_many :coastal_erosion_protection_outcomes, dependent: :destroy
    has_one :state, inverse_of: :project, dependent: :destroy
    has_many :asite_submissions, inverse_of: :project, dependent: :destroy
    accepts_nested_attributes_for :funding_values, allow_destroy: true
    accepts_nested_attributes_for :flood_protection_outcomes, allow_destroy: true
    accepts_nested_attributes_for :flood_protection2040_outcomes, allow_destroy: true
    accepts_nested_attributes_for :coastal_erosion_protection_outcomes, allow_destroy: true
    accepts_nested_attributes_for :funding_contributors

    before_validation :set_slug, on: :create

    delegate :archived?, :draft?, :completed?, :submitted?, :updatable?, :updated?, :finished?, to: :submission_state

    def self.submitted
      joins(:state).merge(PafsCore::State.submitted)
    end

    def self.refreshable
      joins(:state).merge(PafsCore::State.refreshable)
    end

    def to_param
      slug
    end

    def owner
      area_projects.ownerships.map(&:area).first
    end

    def storage_path
      @storage_path ||= File.join(to_param, version.to_s)
    end

    def flooding?
      fluvial_flooding? || tidal_flooding? || groundwater_flooding? ||
        surface_water_flooding? || sea_flooding? || reservoir_flooding?
    end

    def project_protects_households?
      project_type != "ENV_WITHOUT_HOUSEHOLDS"
    end

    # rubocop:disable Style/HashSyntax
    def submission_state
      Bstard.define do |fsm|
        fsm.initial current_state
        fsm.event :archived, :draft => :archived
        fsm.event :complete, :draft => :completed, :updatable => :updated
        fsm.event :submit, :draft => :submitted, :completed => :submitted, :updated => :finished
        fsm.event :unlock, :archived => :draft, :completed => :draft, :submitted => :draft
        fsm.event :refresh, :completed => :updatable, :submitted => :updatable
        fsm.when :any do |_event, _prev_state, new_state|
          state.state = new_state
          state.save!
        end
      end
    end
    # rubocop:enable Style/HashSyntax

    def status
      current_state.to_sym
    end

    def total_for_funding_source(source)
      source_total = 0
      funding_values.each do |fv|
        source_total += fv.public_send("#{source}_total")
      end
      source_total
    end

    def total_households_flood_protected_by_category(category)
      households = 0
      flood_protection_outcomes.each do |fo|
        households += fo[category].to_i
      end
      households
    end

    def total_households_flood_protected_2040_by_category(category)
      households = 0
      flood_protection2040_outcomes.each do |fo|
        households += fo[category].to_i
      end
      households
    end

    def total_households_coastal_protected_by_category(category)
      households = 0
      coastal_erosion_protection_outcomes.each do |fo|
        households += fo[category].to_i
      end
      households
    end

    def ea?
      # It looks like Projects could belong to more than one area.
      # If this project does belong to an EA area, we can return true
      # in this test as it is an EA project even if it is also
      # a PSO or RMA project
      areas.map(&:area_type).include?(PafsCore::Area::EA_AREA)
    end

    def pso?
      # It looks like Projects could belong to more than one area.
      # If this project does belong to an PSO area, we can return true
      # in this test as it is an PSO project even if it is also
      # a RMA or EA project
      areas.map(&:area_type).include?(PafsCore::Area::PSO_AREA)
    end

    def rma?
      # It looks like Projects could belong to more than one area.
      # If this project does belong to an RMA area, we can return true
      # in this test as it is an RMA project even if it is also
      # a PSO or EA project
      areas.map(&:area_type).include?(PafsCore::Area::RMA_AREA)
    end

    %w[private public other_ea].each do |contributor_type|
      define_method "#{contributor_type}_contributor_names" do
        funding_contributors.where(
          contributor_type: "#{contributor_type}_contributions"
        ).pluck(:name).uniq.join(", ")
      end
    end

    def first_financial_year
      funding_values.pluck(:financial_year).min
    end

    private

    def set_slug
      self.slug = reference_number.parameterize.upcase
    end

    def current_state
      if state.nil?
        with_lock do
          create_state(state: "draft") if state.nil?
        end
      end

      state.state || "draft"
    end
  end
end
