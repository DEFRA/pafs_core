# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::WholeLifeCarbonStep, type: :model do
  subject { build(:whole_life_carbon_step) }

  it_behaves_like "a project step"

  it_behaves_like "does not modify project attributes"
end
