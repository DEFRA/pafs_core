# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::FcermGiaFundingSourcesStep, type: :model do
  subject { build(:fcerm_gia_funding_sources_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that at least one funding source is selected" do
      subject.asset_replacement_allowance = false
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include "The project must have at least one additional FCRM Grant in aid funding source."
    end
  end

  describe "#update" do
    subject { create(:fcerm_gia_funding_sources_step) }

    let(:params) do
      ActionController::Parameters.new({ fcerm_gia_funding_sources_step: { environment_statutory_funding: "1" } })
    end

    let(:error_params) do
      ActionController::Parameters.new({ funding_sources_step: { asset_replacement_allowance: nil } })
    end

    it "saves the state of valid params" do
      expect(subject.update(params)).to be true
      expect(subject.environment_statutory_funding).to be true
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to be false
    end
  end
end
