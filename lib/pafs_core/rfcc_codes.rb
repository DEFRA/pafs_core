# frozen_string_literal: true

# require "pafs_core/models/area.rb"

module PafsCore
  RFCC_CODES = %w[AC AE AN NO NW SN SO SW TH TR TS WX YO].freeze

  # map RFCC codes to names
  RFCC_CODE_NAMES_MAP = {
    "AC" => "Anglian (Great Ouse)",
    "AE" => "Anglian Eastern",
    "AN" => "Anglian Northern",
    "NO" => "Northumbria",
    "NW" => "North West",
    "SN" => "Severn & Wye",
    "SO" => "Southern",
    "SW" => "Southwest",
    "TH" => "Thames",
    "TR" => "Trent",
    "TS" => "Test",
    "WX" => "Wessex",
    "YO" => "Yorkshire"
  }.freeze
end
