# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::PublicContributorsStep, type: :model do
  subject { described_class.new(project) }

  let(:project) { create(:project) }

  describe "attributes" do
    it_behaves_like "a project step"
  end
end
