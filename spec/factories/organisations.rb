# frozen_string_literal: true

FactoryBot.define do
  factory :organisation, class: "PafsCore::Organisation" do
    name { Faker::Lorem.sentence }

    trait :rma do
      organisation_type { "RMA" }
    end

    trait :authority do
      organisation_type { "Authority" }
    end

    trait :pso do
      organisation_type { "PSO" }
    end
  end
end
