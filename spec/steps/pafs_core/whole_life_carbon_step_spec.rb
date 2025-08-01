# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::WholeLifeCarbonStep, type: :model do
  subject { build(:whole_life_carbon_step) }

  it_behaves_like "a project step"

  it_behaves_like "does not modify project attributes"

  describe "#whole_life_carbon_required_fields_empty?" do
    it "returns true if all carbon cost fields are blank" do
      subject.project.carbon_cost_build = nil
      subject.project.carbon_cost_operation = nil
      expect(subject.whole_life_carbon_required_fields_empty?).to be true
    end

    it "returns false if any carbon cost field is present" do
      subject.project.carbon_cost_build = 100
      expect(subject.whole_life_carbon_required_fields_empty?).to be false
    end
  end

  describe "#carbon_impact_presenter" do
    it "returns a CarbonImpactPresenter instance" do
      presenter = subject.carbon_impact_presenter
      expect(presenter).to be_a(PafsCore::CarbonImpactPresenter)
    end
  end
end
