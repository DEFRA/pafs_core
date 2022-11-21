# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ArableLandCreatedOrEnhancedStep, type: :model do
  subject { build(:arable_land_created_or_enhanced_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :arable_land has been set" do
      subject.arable_land = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:arable_land])
        .to include "You must select yes or no"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :environmental_benefits when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.arable_land).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.arable_land).to be false
    end

    context "when updating :arable_land from true to false" do
      subject { create(:arable_land_created_or_enhanced_step, project: project) }

      let(:project) do
        create(
          :project,
          arable_land: true,
          hectares_of_arable_land_lake_habitat_created_or_enhanced: 12
        )
      end

      it "resets :hectares_of_arable_land_lake_habitat_created_or_enhanced to nil" do
        subject.update(false_params)
        project.reload

        expect(project.hectares_of_woodland_habitat_created_or_enhanced).to be_nil
      end
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end
    end
  end

  def make_params(value)
    ActionController::Parameters.new(
      arable_land_created_or_enhanced_step: { arable_land: value }
    )
  end
end
