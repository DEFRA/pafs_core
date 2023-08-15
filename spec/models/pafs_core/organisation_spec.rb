# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::Organisation do
  describe "attributes" do
    subject { create(:organisation, :rma) }

    it { is_expected.to validate_presence_of :name }

    it { is_expected.to validate_presence_of :organisation_type }

    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
