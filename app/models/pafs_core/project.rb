# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class Project < ActiveRecord::Base
    validates :reference_number, presence: true, uniqueness: { scope: :version }
    validates :reference_number, format: { with: /\A(AC|AE|AN|NO|NW|SN|SO|SW|TH|TR|WX|YO)C501E\/\d{3}A\/\d{3}A\z/,
                                           message: "has an invalid format" }
    validates :version, presence: true

    has_many :area_projects
    has_many :areas, through: :area_projects
    before_validation :set_slug, on: :create

    def to_param
      slug
    end

    def owner
      area_projects.ownerships.map(&:area).first
    end

  private
    def set_slug
      self.slug = reference_number.parameterize.upcase
    end
  end
end
