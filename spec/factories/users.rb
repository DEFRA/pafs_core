# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user, class: "PafsCore::User" do
    first_name { "Ray" }
    last_name { "Clemence" }
    email

    transient do
      area { nil }
    end

    after(:create) do |user, evaluator|
      user.user_areas.create(area: evaluator.area, primary: true) if evaluator.area
    end

    trait :ea do
      after(:create) do |user|
        area = PafsCore::Area.ea_areas.first || create(:ea_area)
        user.user_areas.create(area: area, primary: true)
      end
    end

    trait :pso do
      after(:create) do |user|
        area = PafsCore::Area.pso_areas.first || create(:pso_area)
        user.user_areas.create(area: area, primary: true)
      end
    end

    trait :rma do
      after(:create) do |user|
        area = PafsCore::Area.rma_areas.first || create(:rma_area)
        user.user_areas.create(area: area, primary: true)
      end
    end
  end
end
