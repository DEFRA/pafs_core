# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::StandardOfProtectionCoastalStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:standard_of_protection_coastal_step) }

    it_behaves_like "a project step"

    it "validates that :coastal_protection_before is present" do
      subject.coastal_protection_before = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:coastal_protection_before]).to include
      "^Select the option that shows the length of time before coastal \
      erosion affects the area likely to benefit from the project."
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:standard_of_protection_coastal_step) }
    let(:params) do
      HashWithIndifferentAccess.new({
        standard_of_protection_coastal_step: {
          coastal_protection_before: "1",
        }
      })
    end
    let(:error_params) do
      HashWithIndifferentAccess.new({
        standard_of_protection_coastal_step: {
          coastal_protection_before: "2011"
        }
      })
    end

    it "saves the :coastal_protection_before when valid" do
      expect(subject.coastal_protection_before).not_to eq 1
      expect(subject.update(params)).to be true
      expect(subject.coastal_protection_before).to eq 1
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end

  describe "#coastal_erosion_before_options" do
    subject { FactoryGirl.build(:standard_of_protection_coastal_step) }

    it "should return an array of options" do
      array_of_options = [:less_than_one_year, :one_to_four_years, :five_to_nine_years, :ten_years_or_more]

      expect(subject.coastal_erosion_before_options).to eq array_of_options
    end
  end
end
