# frozen_string_literal: true

module PafsCore
  module DateUtils
    VALID_MONTH_RANGE = (1..12)
    VALID_YEAR_RANGE = (2000..2100)

    def date_present?(date_name)
      send("#{date_name}_month").present? && send("#{date_name}_year").present?
    end

    def date_plausible?(date_name)
      month_plausible?(date_name) && year_plausible?(date_name)
    end

    def month_plausible?(date_name)
      VALID_MONTH_RANGE.cover?(send("#{date_name}_month").to_i)
    end

    def year_plausible?(date_name)
      VALID_YEAR_RANGE.cover?(send("#{date_name}_year").to_i)
    end

    def date_later_than?(date_name, other_date_name)
      Date.new(send("#{date_name}_year").to_i, send("#{date_name}_month").to_i, 1) >
        Date.new(send("#{other_date_name}_year").to_i, send("#{other_date_name}_month").to_i, 1)
    end

    def date_in_future?(date_name)
      send("#{date_name}_year").to_i > Time.zone.today.year || (
        send("#{date_name}_year").to_i == Time.zone.today.year &&
        send("#{date_name}_month").to_i > Time.zone.today.month
      )
    end
  end
end
