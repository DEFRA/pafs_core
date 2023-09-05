# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::LocationStep, type: :model do
  describe "attributes" do
    subject { build(:location_step) }

    it_behaves_like "a project step"
  end

  describe "#update", :vcr do
    subject { create(:location_step) }

    let(:params) do
      ActionController::Parameters.new(
        {
          location_step: {
            grid_reference: "TF1030089900"
          }
        }
      )
    end
    let(:error_params) do
      ActionController::Parameters.new(
        {
          location_step: {
            grid_reference: "AA0000000000"
          }
        }
      )
    end

    it "saves the :grid_reference when valid" do
      expect(subject.grid_reference).not_to eq "TF1030089900"
      expect(subject.update(params)).to be true
      expect(subject.grid_reference).to eq "TF1030089900"
    end

    it "saves the :region when valid" do
      expect(subject.region).not_to eq "East Midlands"
      expect(subject.update(params)).to be true
      expect(subject.region).to eq "East Midlands"
    end

    it "saves the :county when valid" do
      expect(subject.county).not_to eq "Lincolnshire"
      expect(subject.update(params)).to be true
      expect(subject.county).to eq "Lincolnshire"
    end

    it "saves the :parliamentary_constituency when valid" do
      expect(subject.parliamentary_constituency).not_to eq "Gainsborough"
      expect(subject.update(params)).to be true
      expect(subject.parliamentary_constituency).to eq "Gainsborough"
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to be false
    end
  end
end
