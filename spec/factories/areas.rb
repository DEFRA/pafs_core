# frozen_string_literal: true

FactoryBot.define do
  factory :area, class: "PafsCore::Area" do
    name { "Area #{Faker::Lorem.unique.sentence}" }

    factory :country do
      area_type { "Country" }

      trait :with_ea_areas do
        after(:create) do |country|
          FactoryBot.create_list(:ea_area, 2, parent_id: country.id)
        end
      end

      trait :with_ea_and_pso_areas do
        after(:create) do |country|
          FactoryBot.create_list(:ea_area, 2, :with_pso_areas, parent_id: country.id)
        end
      end

      trait :with_full_hierarchy do
        after(:create) do |country|
          FactoryBot.create_list(:ea_area, 2, :with_pso_and_rma_areas, parent_id: country.id)
        end
      end

      trait :with_full_hierarchy_and_projects do
        after(:create) do |country|
          create(:ea_area, :with_pso_rma_areas_and_full_projects, parent_id: country.id)
        end
      end
    end

    factory :ea_area do
      area_type { "EA Area" }
      parent { PafsCore::Area.country || create(:country) }

      trait :with_pso_areas do
        after(:create) do |area|
          FactoryBot.create_list(:pso_area, 2, parent_id: area.id)
        end
      end

      trait :with_pso_and_rma_areas do
        after(:create) do |area|
          FactoryBot.create_list(:pso_area, 2, :with_rma_areas, parent_id: area.id)
        end
      end

      trait :with_pso_rma_areas_and_full_projects do
        after(:create) do |area|
          create(:pso_area, :with_rma_areas_and_projects, parent_id: area.id)
        end
      end
    end

    factory :pso_area do
      area_type { "PSO Area" }
      parent { PafsCore::Area.country || create(:country) }
      sub_type { PafsCore::RFCC_CODES.sample }

      trait :with_rma_areas do
        after(:create) do |pso_area|
          FactoryBot.create_list(:rma_area, 2, :with_project, parent_id: pso_area.id)
        end
      end

      trait :with_rma_areas_and_projects do
        after(:create) do |pso_area|
          create(:rma_area, :with_full_projects, parent_id: pso_area.id)
        end

        after(:create) do |pso_area|
          5.times do
            create(:full_project)
            project = PafsCore::Project.last
            pso_area.area_projects.create(project: project, owner: true)
            create(:coastal_erosion_protection_outcomes, financial_year: -1, project_id: project.id)
            create(:flood_protection_outcomes, financial_year: -1, project_id: project.id)
            create(:funding_value, :previous_year, project: project)
            12.times do |n|
              year = 2016 + n
              create(:coastal_erosion_protection_outcomes, financial_year: year, project_id: project.id)
              create(:flood_protection_outcomes, financial_year: year, project_id: project.id)
              create(:funding_value, financial_year: year, project: project)
            end
          end
        end
      end
    end

    factory :rma_area do
      area_type { "RMA" }
      identifier { Faker::Lorem.characters(number: 10) }
      sub_type { PafsCore::Area.authorities.first&.identifier || create(:authority).identifier }

      parent { PafsCore::Area.pso_areas.first || create(:pso_area) }

      trait :with_project do
        after(:create) do |rma_area|
          p = PafsCore::Project.create(
            name: "Project #{rma_area.name}",
            reference_number: PafsCore::ProjectService.generate_reference_number("TH"),
            version: 0
          )
          p.save

          rma_area.area_projects.create(project_id: p.id, owner: true)
        end
      end

      trait :with_full_projects do
        after(:create) do |rma_area|
          5.times do
            create(:full_project)
            project = PafsCore::Project.last
            rma_area.area_projects.create(project: project, owner: true)
            create(:coastal_erosion_protection_outcomes, financial_year: -1, project_id: project.id)
            create(:flood_protection_outcomes, financial_year: -1, project_id: project.id)
            create(:funding_value, :previous_year, project: project)
            12.times do |n|
              year = 2016 + n
              create(:coastal_erosion_protection_outcomes, financial_year: year, project_id: project.id)
              create(:flood_protection_outcomes, financial_year: year, project_id: project.id)
              create(:funding_value, financial_year: year, project: project)
            end
          end
        end
      end
    end

    factory :authority do
      area_type { "Authority" }
      name { "Local Authority" }
      identifier { "LA" }
    end
  end
end
