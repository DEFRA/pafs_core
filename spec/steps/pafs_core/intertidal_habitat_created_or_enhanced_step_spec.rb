# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::IntertidalHabitatCreatedOrEnhancedStep, type: :model do
  subject { build(:intertidal_habitat_created_or_enhanced_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :intertidalhas been set" do
      subject.intertidal_habitat = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:intertidal_habitat])
        .to include "You must select yes or no"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :intertidal when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.intertidal_habitat).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.intertidal_habitat).to be false
    end

    context "when updating :intertidal from true to false" do
      subject { create(:intertidal_habitat_created_or_enhanced_step, project: project) }

      let(:project) do
        create(
          :project,
          intertidal_habitat: true,
          hectares_of_intertidal_habitat_created_or_enhanced: 12
        )
      end

      it "resets :hectares_of_intertidal_habitat_created_or_enhanced to nil" do
        subject.update(false_params)
        project.reload

        expect(project.hectares_of_intertidal_habitat_created_or_enhanced).to be_nil
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
      intertidal_habitat_created_or_enhanced_step: { intertidal_habitat: value }
    )
  end
end
