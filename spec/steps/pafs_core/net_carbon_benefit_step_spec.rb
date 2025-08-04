# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::NetCarbonBenefitStep, type: :model do
  subject { create(:net_carbon_benefit_step) }

  it_behaves_like "a project step"

  describe "validations" do
    it_behaves_like "validates numericality", :net_carbon_benefit_step, :carbon_savings_net_economic_benefit, negatives_allowed: true
  end

  it_behaves_like "updates project attributes", :net_carbon_benefit_step, :carbon_savings_net_economic_benefit, negatives_allowed: true
end
