# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CarbonPrepareStep, type: :model do
  subject { build(:carbon_prepare_step) }

  it_behaves_like "a project step"

  describe "#update" do
    let(:params) { ActionController::Parameters.new({}) }

    it "returns true as this is an informational step" do
      expect(subject.update(params)).to be true
    end

    it "does not modify any project attributes" do
      original_attributes = subject.project.attributes.dup
      subject.update(params)
      expect(subject.project.attributes).to eq original_attributes
    end
  end
end
