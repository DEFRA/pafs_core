# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CarbonCostOperationStep, type: :model do
  subject { create(:carbon_cost_operation_step) }

  it_behaves_like "a project step"

  describe "validations" do
    it_behaves_like "validates numericality", :carbon_cost_operation
  end

  it_behaves_like "updates project attributes", :carbon_cost_operation_step, :carbon_cost_operation
end
