# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ProgramUpload do
  describe "attributes" do
    subject { create(:program_upload) }

    it { is_expected.to validate_numericality_of :number_of_records }

    it "validates the presence of a filename via the :base attribute" do
      subject.filename = nil
      expect(subject.valid?).to be false
      expect(subject.errors[:filename].count).to eq 0
      expect(subject.errors[:base].count).to eq 1
    end
  end
end
