# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ComprehensiveRestorationStep, type: :model do
  subject { FactoryBot.build(:comprehensive_restoration_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :comprehensive_restoration  has been set" do
      subject.comprehensive_restoration = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:comprehensive_restoration])
        .to include "^You must select yes or no"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :environmental_benefits when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.comprehensive_restoration).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.comprehensive_restoration).to be false
    end

    context "when updating :arable_land from true to false" do
      subject { FactoryBot.create(:comprehensive_restoration_step, project: project) }

      let(:project) do
        FactoryBot.create(
          :project,
          comprehensive_restoration: true,
          kilometres_of_watercourse_enhanced_or_created_comprehensive: 12
        )
      end

      it "resets :kilometres_of_watercourse_enhanced_or_created_comprehensive to nil" do
        subject.update(false_params)
        project.reload

        expect(project.kilometres_of_watercourse_enhanced_or_created_comprehensive).to be nil
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
      comprehensive_restoration_step: { comprehensive_restoration: value }
    )
  end
end
