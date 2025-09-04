# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CarbonPrepareStep, type: :model do
  subject { build(:carbon_prepare_step) }

  it_behaves_like "a project step"

  it_behaves_like "does not modify project attributes"
end
