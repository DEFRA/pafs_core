# frozen_string_literal: true

module PafsCore
  class Organisation < ApplicationRecord
    ORGANISATION_TYPES = [
      RMA = "RMA",
      AUTHORITY = "Authority",
      PSO = "PSO"
    ].freeze

    validates :name, :organisation_type, presence: true
    validates :name, uniqueness: true

    validates :organisation_type, inclusion: { in: ORGANISATION_TYPES }
  end
end
