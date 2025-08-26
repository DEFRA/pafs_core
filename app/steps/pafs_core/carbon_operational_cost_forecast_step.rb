# frozen_string_literal: true

module PafsCore
  class CarbonOperationalCostForecastStep < BasicStep
    include PafsCore::Carbon

    validates :carbon_operational_cost_forecast, presence: {
      message: "You must enter a value"
    }

    validates :carbon_operational_cost_forecast, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      allow_blank: false,
      message: "The value entered can not be negative"
    }

    private

    def step_params(params)
      params
        .require(:carbon_operational_cost_forecast_step)
        .permit(
          :carbon_operational_cost_forecast
        )
    end
  end
end
