# frozen_string_literal: true

FactoryBot.define do
  factory :organisation, class: "PafsCore::Organisation" do
    name { Faker::Lorem.sentence }
    organisation_type { "RMA" }
  end
end
