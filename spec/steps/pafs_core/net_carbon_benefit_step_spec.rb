# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::NetCarbonBenefitStep, type: :model do
  subject { create(:net_carbon_benefit_step) }

  it_behaves_like "a project step"

  describe "validations" do
    it_behaves_like "validates numericality", :net_carbon_benefit_step, :carbon_savings_net_economic_benefit, true
  end

  describe "#update" do
    it_behaves_like "updates project attributes", :net_carbon_benefit_step,
                    :carbon_savings_net_economic_benefit, true, true

    it "allows saving a negative carbon savings value" do
      value = Faker::Number.negative.round(0)
      params = ActionController::Parameters.new(
        net_carbon_benefit_step: { carbon_savings_net_economic_benefit: value }
      )

      expect { subject.update(params) }.to change { subject.project.reload.carbon_savings_net_economic_benefit }.to(value)
    end
  end
end
