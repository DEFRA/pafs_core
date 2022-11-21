# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::AnyEnvironmentalBenefitsStep, type: :model do
  subject { build(:any_environmental_benefits_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :environmental has been set" do
      subject.environmental_benefits = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:environmental_benefits])
        .to include "You must select yes or no"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :environmental_benefits when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.environmental_benefits).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.environmental_benefits).to be false
    end

    context "when updating :environmental_benefits from true to false" do
      subject { create(:any_environmental_benefits_step, project: project) }

      let(:project) do
        create(
          :project,
          woodland: true,
          hectares_of_woodland_habitat_created_or_enhanced: 12
        )
      end

      it "resets the project's om4 attributes to nil" do
        subject.update(false_params)
        project.reload

        expect(project.woodland).to be_nil
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
      any_environmental_benefits_step: { environmental_benefits: value }
    )
  end
end
