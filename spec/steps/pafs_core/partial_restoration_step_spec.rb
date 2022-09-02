# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::PartialRestorationStep, type: :model do
  subject { FactoryBot.build(:partial_restoration_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :partial_restoration has been set" do
      subject.partial_restoration = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:partial_restoration])
        .to include "^You must select yes or no"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :environmental_benefits when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.partial_restoration).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.partial_restoration).to be false
    end

    context "when updating :partial_restoration from true to false" do
      let(:project) do
        FactoryBot.create(
          :project,
          partial_restoration: true,
          kilometres_of_watercourse_enhanced_or_created_partial: 12
        )
      end

      subject { FactoryBot.create(:partial_restoration_step, project: project) }

      it "resets :kilometres_of_watercourse_enhanced_or_created_partial to nil" do
        subject.update(false_params)
        project.reload

        expect(project.kilometres_of_watercourse_enhanced_or_created_partial).to be nil
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
      partial_restoration_step: { partial_restoration: value }
    )
  end
end
