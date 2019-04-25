# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
FactoryBot.define do
  factory :user_area, class: PafsCore::UserArea do
    user_id { 1 }
    area_id { 1 }
    primary { true }
  end
end
