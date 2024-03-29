# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::UserArea do
  describe "attributes" do
    subject { create(:user_area) }

    it "validates presence of" do
      expect(subject).not_to validate_presence_of :primary
    end

    it do
      expect(subject)
        .to validate_uniqueness_of(:user_id)
        .scoped_to(:area_id)
        .with_message("Unable to assign area multiple times")
    end

    it "validates that :area_id is present" do
      subject.area_id = nil
      expect(subject.valid?).to be false
      expect(subject.errors[:area_id]).to include "Select an area"
    end
  end
end
