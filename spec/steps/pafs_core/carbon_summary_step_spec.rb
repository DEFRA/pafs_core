# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CarbonSummaryStep, type: :model do
  subject { build(:carbon_summary_step) }

  it_behaves_like "a project step"

  it_behaves_like "does not modify project attributes"

  describe "#presenter" do
    it "returns a CarbonImpactPresenter instance" do
      presenter = subject.presenter
      expect(presenter).to be_a(PafsCore::CarbonImpactPresenter)
    end
  end
end
