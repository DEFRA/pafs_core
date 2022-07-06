# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::HeathlandHabitatCreatedOrEnhancedStep, type: :model do
  subject { FactoryBot.build(:heathland_habitat_created_or_enhanced_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :heathland has been set" do
      subject.heathland = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:heathland])
        .to include "^You must select yes or no"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :heathland when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.heathland).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.heathland).to be false
    end

    context "when updating :intertidal from true to false" do
      let(:project) do
        FactoryBot.create(
          :project,
          heathland: true,
          hectares_of_heathland_created_or_enhanced: 12
        )
      end

      subject { FactoryBot.create(:heathland_habitat_created_or_enhanced_step, project: project) }

      it "resets :hectares_of_heathland_created_or_enhanced to nil" do
        subject.update(false_params)
        project.reload

        expect(project.hectares_of_heathland_created_or_enhanced).to be nil
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
      heathland_habitat_created_or_enhanced_step: { heathland: value }
    )
  end
end
