# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CoreExtensions::Time::Financial" do
  it "gives the previous year for a date before April" do
    t = Time.utc(2016, 3, 31)

    expect(t.uk_financial_year).to eq 2015
  end

  it "gives the standard year for any date after March 31st" do
    t = Time.utc(2016, 4, 1)

    expect(t.uk_financial_year).to eq 2016
  end
end
