# frozen_string_literal: true

FactoryBot.define do
  factory :flood_protection2040_outcomes, class: "PafsCore::FloodProtection2040Outcome" do
    project_id { 1 }
    financial_year { 2022 }
    households_at_reduced_risk { 100 }
    moved_from_very_significant_and_significant_to_moderate_or_low { 50 }
    households_protected_from_loss_in_20_percent_most_deprived { 25 }
  end
end
