# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::KilometresOfWatercourseEnhancedOrCreatedComprehensiveStep, type: :model do
  subject { FactoryBot.build(:kilometres_of_watercourse_enhanced_or_created_comprehensive_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :kilometres_of_watercourse_enhanced_or_created_comprehensive has been set" do
      subject.kilometres_of_watercourse_enhanced_or_created_comprehensive= nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:kilometres_of_watercourse_enhanced_or_created_comprehensive])
        .to include "^You must include the number of kilometres of watercourse the project will create."
    end
  end
end
