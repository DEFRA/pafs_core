# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CreateHabitatWatercourseStep, type: :model do
  subject { FactoryBot.build(:create_habitat_watercourse_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :arable_land has been set" do
      subject.create_habitat_watercourse = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:create_habitat_watercourse])
        .to include "^You must select yes or no"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :environmental_benefits when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.create_habitat_watercourse).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.create_habitat_watercourse).to be false
    end

    context "when updating :arable_land from true to false" do
      subject { FactoryBot.create(:create_habitat_watercourse_step, project: project) }

      let(:project) do
        FactoryBot.create(
          :project,
          create_habitat_watercourse: true,
          kilometres_of_watercourse_enhanced_or_created_single: 12
        )
      end

      it "resets :kilometres_of_watercourse_enhanced_or_created_single to nil" do
        subject.update(false_params)
        project.reload

        expect(project.kilometres_of_watercourse_enhanced_or_created_single).to be nil
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
      create_habitat_watercourse_step: { create_habitat_watercourse: value }
    )
  end
end
