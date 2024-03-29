# frozen_string_literal: true

module PafsCore
  class Area < ApplicationRecord
    AREA_TYPES = [
      COUNTRY_AREA = "Country",
      EA_AREA      = "EA Area",
      PSO_AREA     = "PSO Area",
      RMA_AREA     = "RMA",
      AUTHORITY = "Authority"
    ].freeze

    attr_accessor :skip_identifier_validation

    validates :name, :area_type, presence: true
    validates :name, uniqueness: true
    validates :identifier, presence: true, if: -> { rma? || authority? }, unless: :skip_identifier_validation
    validates :identifier, uniqueness: true, if: -> { rma? || authority? }, unless: :skip_identifier_validation
    validate :parentage
    validates :area_type, inclusion: { in: AREA_TYPES }
    validates :sub_type, presence: true, if: -> { rma? || pso_area? }

    belongs_to :parent, class_name: "Area", optional: true
    has_many :children, class_name: "Area", foreign_key: "parent_id"
    has_many :area_projects
    has_many :projects, through: :area_projects
    has_one :area_download, inverse_of: :area

    scope :top_level, -> { where(parent_id: nil) }

    def self.country
      find_by(area_type: AREA_TYPES[0])
    end

    def self.ea_areas
      where(area_type: AREA_TYPES[1])
    end

    def self.pso_areas
      where(area_type: AREA_TYPES[2])
    end

    def self.rma_areas
      where(area_type: AREA_TYPES[3])
    end

    def self.authorities
      where(area_type: AREA_TYPES[4])
    end

    def country?
      area_type == AREA_TYPES[0]
    end

    def ea_area?
      area_type == AREA_TYPES[1]
    end

    def pso_area?
      area_type == AREA_TYPES[2]
    end

    def rma?
      area_type == AREA_TYPES[3]
    end

    def authority?
      area_type == AREA_TYPES[4]
    end

    def ea_parent
      return self if ea_area?

      if ea_area?
        self
      elsif pso_area?
        parent
      elsif rma?
        parent.parent
      else
        raise "Cannot find ea parent for #{name}"
      end
    end

    def parentage
      if !country? && !authority? && parent_id.blank?
        errors.add(:parent_id, "can't be blank")
      elsif (country? || authority?) && parent_id.present?
        errors.add(:parent_id, "must be blank")
      end
    end
  end
end
