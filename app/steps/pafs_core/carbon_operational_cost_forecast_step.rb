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
      permitted_params = params
                         .require(:carbon_operational_cost_forecast_step)
                         .permit(
                           :carbon_operational_cost_forecast
                         )

      # Round the carbon_operational_cost_forecast to 0 decimal
      if permitted_params[:carbon_operational_cost_forecast].present?
        permitted_params[:carbon_operational_cost_forecast] =
          permitted_params[:carbon_operational_cost_forecast].to_f.round(0)
      end

      permitted_params
    end
  end
end
