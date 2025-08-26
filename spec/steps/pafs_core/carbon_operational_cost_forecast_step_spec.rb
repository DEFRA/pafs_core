# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CarbonOperationalCostForecastStep, type: :model do
  subject { create(:carbon_operational_cost_forecast_step) }

  it_behaves_like "a project step"

  describe "validations" do
    it_behaves_like "validates numericality", :carbon_operational_cost_forecast_step, :carbon_operational_cost_forecast, negatives_allowed: false, blanks_allowed: false
  end

  describe "#update" do
    it_behaves_like "updates project attributes", :carbon_operational_cost_forecast_step, :carbon_operational_cost_forecast,
                    negatives_allowed: false, only_integers: true, blanks_allowed: false
  end
end
