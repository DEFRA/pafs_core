# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::PondsLakesHabitatCreatedOrEnhancedStep, type: :model do
  subject { FactoryBot.build(:ponds_lakes_habitat_created_or_enhanced_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :ponds_lakes has been set" do
      subject.ponds_lakes = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:ponds_lakes])
        .to include "^You must select yes or no"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :heathland when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.ponds_lakes).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.ponds_lakes).to be false
    end

    context "when updating :ponds_lakes from true to false" do
      subject { FactoryBot.create(:ponds_lakes_habitat_created_or_enhanced_step, project: project) }

      let(:project) do
        FactoryBot.create(
          :project,
          ponds_lakes: true,
          hectares_of_pond_or_lake_habitat_created_or_enhanced: 12
        )
      end

      it "resets :hectares_of_pond_or_lake_habitat_created_or_enhancedto nil" do
        subject.update(false_params)
        project.reload

        expect(project.hectares_of_pond_or_lake_habitat_created_or_enhanced).to be nil
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
      ponds_lakes_habitat_created_or_enhanced_step: { ponds_lakes: value }
    )
  end
end
