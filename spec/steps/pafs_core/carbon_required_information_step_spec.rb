# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CarbonRequiredInformationStep, type: :model do
  subject { build(:carbon_required_information_step) }

  it_behaves_like "a project step"

  it_behaves_like "does not modify project attributes"
end
