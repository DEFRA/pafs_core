# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CarbonCostSequesteredStep, type: :model do
  subject { create(:carbon_cost_sequestered_step) }

  it_behaves_like "a project step"

  describe "validations" do
    it_behaves_like "validates numericality", :carbon_cost_sequestered
  end

  it_behaves_like "updates project attributes", :carbon_cost_sequestered_step, :carbon_cost_sequestered
end
