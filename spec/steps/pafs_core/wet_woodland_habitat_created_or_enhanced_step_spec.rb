# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::WetWoodlandHabitatCreatedOrEnhancedStep, type: :model do
  subject { build(:wet_woodland_habitat_created_or_enhanced_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :wet_woodland has been set" do
      subject.wet_woodland = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:wet_woodland])
        .to include "You must select yes or no"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :heathland when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.wet_woodland).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.wet_woodland).to be false
    end

    context "when updating :wet_woodland from true to false" do
      subject { create(:wet_woodland_habitat_created_or_enhanced_step, project: project) }

      let(:project) do
        create(
          :project,
          wet_woodland: true,
          hectares_of_wet_woodland_habitat_created_or_enhanced: 12
        )
      end

      it "resets :hectares_of_wet_woodland_habitat_created_or_enhanced to nil" do
        subject.update(false_params)
        project.reload

        expect(project.hectares_of_wet_woodland_habitat_created_or_enhanced).to be_nil
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
      wet_woodland_habitat_created_or_enhanced_step: { wet_woodland: value }
    )
  end
end
