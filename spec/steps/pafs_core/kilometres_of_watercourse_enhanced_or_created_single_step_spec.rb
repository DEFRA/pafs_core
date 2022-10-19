# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::KilometresOfWatercourseEnhancedOrCreatedSingleStep, type: :model do
  subject { build(:kilometres_of_watercourse_enhanced_or_created_single_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :kilometres_of_watercourse_enhanced_or_created_comprehensive has been set" do
      subject.kilometres_of_watercourse_enhanced_or_created_single = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:kilometres_of_watercourse_enhanced_or_created_single])
        .to include "^You must include the number of kilometres your project will create."
    end
  end
end
