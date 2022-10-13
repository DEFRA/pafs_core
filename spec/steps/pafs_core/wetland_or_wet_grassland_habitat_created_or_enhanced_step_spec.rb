# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::WetlandOrWetGrasslandHabitatCreatedOrEnhancedStep, type: :model do
  subject { FactoryBot.build(:wetland_or_wet_grassland_habitat_created_or_enhanced_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :wetland_or_wet_grassland has been set" do
      subject.wetland_or_wet_grassland = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:wetland_or_wet_grassland])
        .to include "^You must select yes or no"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :heathland when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.wetland_or_wet_grassland).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.wetland_or_wet_grassland).to be false
    end

    context "when updating :wet_woodland from true to false" do
      subject { FactoryBot.create(:wetland_or_wet_grassland_habitat_created_or_enhanced_step, project: project) }

      let(:project) do
        FactoryBot.create(
          :project,
          wetland_or_wet_grassland: true,
          hectares_of_wetland_or_wet_grassland_created_or_enhanced: 12
        )
      end

      it "resets :hectares_of_wetland_or_wet_grassland_created_or_enhancedto nil" do
        subject.update(false_params)
        project.reload

        expect(project.hectares_of_wetland_or_wet_grassland_created_or_enhanced).to be nil
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
      wetland_or_wet_grassland_habitat_created_or_enhanced_step: { wetland_or_wet_grassland: value }
    )
  end
end
