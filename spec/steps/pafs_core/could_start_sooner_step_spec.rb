# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CouldStartSoonerStep, type: :model do
  describe "attributes" do
    subject { build(:could_start_sooner_step) }

    it_behaves_like "a project step"

    it "validates that :could_start_early has been set" do
      subject.could_start_early = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:could_start_early]).to include "Tell us if the project can start earlier"
    end
  end

  describe "#update" do
    subject { create(:could_start_sooner_step) }

    let(:true_params) { ActionController::Parameters.new({ could_start_sooner_step: { could_start_early: "true" } }) }
    let(:false_params) { ActionController::Parameters.new({ could_start_sooner_step: { could_start_early: "false" } }) }
    let(:error_params) { ActionController::Parameters.new({ could_start_sooner_step: { could_start_early: nil } }) }

    it "saves the :could_start_early when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.could_start_early).to be true
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to be false
    end
  end
end
