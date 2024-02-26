# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::DateUtils do
  include described_class

  attr_accessor :test_date_year
  attr_accessor :test_date_month

  describe "#date_in_future?" do
    context "when the date is in the future" do
      it "returns true when year is greater than current year" do
        @test_date_year = Time.zone.today.year + 1
        expect(date_in_future?("test_date")).to be_truthy
      end

      it "returns true when year is equal to current year and month is greater than current month" do
        @test_date_year = Time.zone.today.year
        @test_date_month = Time.zone.today.month + 1
        expect(date_in_future?("test_date")).to be_truthy
      end
    end

    context "when the date is in the past" do
      it "returns false when year is lesser than current year" do
        @test_date_year = Time.zone.today.year - 1
        expect(date_in_future?("test_date")).to be_falsey
      end

      it "returns false when year is equal to current year and month is lesser than current month" do
        @test_date_year = Time.zone.today.year
        @test_date_month = Time.zone.today.month - 1
        expect(date_in_future?("test_date")).to be_falsey
      end
    end

    context "when the date is today" do
      it "returns false when year is equal to current year and month is equal to current month" do
        @test_date_year = Time.zone.today.year
        @test_date_month = Time.zone.today.month
        expect(date_in_future?("test_date")).to be_falsey
      end
    end
  end
end
