# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::HectaresOfHeathlandCreatedOrEnhancedStep, type: :model do
  subject { FactoryBot.build(:hectares_of_heathland_created_or_enhanced_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :hectares_of_heathland_created_or_enhanced has been set" do
      subject.hectares_of_heathland_created_or_enhanced= nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:hectares_of_heathland_created_or_enhanced])
        .to include "^You must include the number of hectares your project will create."
    end
  end
end
