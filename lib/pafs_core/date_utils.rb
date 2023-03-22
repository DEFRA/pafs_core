# frozen_string_literal: true

module PafsCore
  module DateUtils
    VALID_MONTH_RANGE = (1..12)
    VALID_YEAR_RANGE = (2000..2100)

    def date_present?(date_name)
      send("#{date_name}_month").present? && send("#{date_name}_year").present?
    end

    def date_in_range?(date_name)
      VALID_MONTH_RANGE.cover?(send("#{date_name}_month").to_i) &&
        VALID_YEAR_RANGE.cover?(send("#{date_name}_year").to_i)
    end

    def date_later_than?(date_name, other_date_name)
      return false unless date_in_range?(date_name) && date_in_range?(other_date_name)

      Date.new(send("#{date_name}_year").to_i, send("#{date_name}_month").to_i, 1) >
        Date.new(send("#{other_date_name}_year").to_i, send("#{other_date_name}_month").to_i, 1)
    end
  end
end
