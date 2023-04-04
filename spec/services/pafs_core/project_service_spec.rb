# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ProjectService do
  subject(:service) { described_class.new(service_user) }

  let(:pso_area_1) { create(:pso_area) }
  let(:rma_area_1) { create(:rma_area, parent_id: pso_area_1.id) }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin_user) { create(:user, admin: true) }
  let(:service_user) { user }

  before do
    user.user_areas.create(area_id: rma_area_1.id, primary: true)
    other_user.user_areas.create(area_id: pso_area_1.id, primary: true)
    # the following is to support testing that an admin user can search for projects within their area as well as across all areas
    admin_user.user_areas.create(area_id: rma_area_1.id, primary: true)
  end

  describe "#search" do
    let!(:user_draft_project) { described_class.new(user).create_project(state: create(:state, :draft)) }
    let!(:user_submitted_project) { described_class.new(user).create_project(state: create(:state, :submitted)) }
    let!(:other_user_project) { described_class.new(other_user).create_project(state: create(:state, :draft)) }
    let(:search_options) { {} }
    let(:all_search_options) { { q: search_term }.merge(search_options) }

    before do
      described_class.new(user).create_project(state: create(:state, :archived))
      described_class.new(admin_user).create_project(state: create(:state, :draft))
    end

    RSpec.shared_examples "returns only the matching project" do
      it "returns the matching project" do
        expect(service.search(all_search_options)).to include(matching_project)
      end

      it "does not return the non-matching project" do
        expect(service.search(all_search_options)).not_to include(non_matching_project)
      end
    end

    RSpec.shared_examples "matches on project number" do
      let(:matching_project) { user_draft_project }
      let(:non_matching_project) { user_submitted_project }

      context "with a match by project number" do
        let(:search_term) { user_draft_project.reference_number }

        it_behaves_like "returns only the matching project"
      end
    end

    RSpec.shared_examples "matches on project name" do
      let(:matching_project) { user_draft_project }
      let(:non_matching_project) { user_submitted_project }

      context "with a match by project name" do
        let(:search_term) { user_draft_project.name[2..6] }

        before { user_draft_project.update(name: Faker::Lorem.sentence) }

        it_behaves_like "returns only the matching project"
      end
    end

    context "when the user does not have admin rights" do
      let(:service_user) { user }

      it "returns all projects for the current user's area" do
        expect(service.search.count).to eq(3)
      end

      it "does not return projects for the other user's area" do
        service.search.each do |result|
          expect(result.creator.primary_area.id).to eq(user.primary_area.id)
        end
      end

      it "returns all projects for a given user and state" do
        results = service.search(state: "submitted")

        expect(results.count).to eq(1)
        expect(results.first.status).to eq(:submitted)
      end

      context "with a search term" do
        let(:non_matching_project) { user_submitted_project }

        it_behaves_like "matches on project number"
        it_behaves_like "matches on project name"
      end

      context "with the archived option" do
        it "returns the archived project" do
          results = service.search(state: "archived")

          expect(results.count).to eq(1)
          expect(results.first.status).to eq(:archived)
        end
      end

      context "with the access_all_areas option" do
        it "returns an error" do
          expect { service.search(access_all_areas: true) }.to raise_error StandardError
        end
      end
    end

    context "when the user has admin rights with the access_all_areas option" do
      let(:service_user) { admin_user }
      let(:search_options) { { access_all_areas: true } }

      it "returns all projects" do
        expect(service.search(search_options).count).to eq(PafsCore::Project.count)
      end

      context "with a search term" do
        it_behaves_like "matches on project number"
        it_behaves_like "matches on project name"

        context "with a match by RMA" do
          let(:search_term) { rma_area_1.name[3..9] }
          let(:matching_project) { user_draft_project }
          let(:non_matching_project) { other_user_project }

          it_behaves_like "returns only the matching project"
        end
      end
    end
  end

  describe "#new_project" do
    let(:reference_number) { "#{PafsCore::PSO_RFCC_MAP[pso_area_1.name]}C501E" }
    let(:project) { subject.new_project }

    it "builds a new project model without saving to the database" do
      expect { project }.not_to change(PafsCore::Project, :count)
    end

    it "builds the correct type of object" do
      expect(project).to be_a PafsCore::Project
    end

    it "initializes the project version correctly" do
      expect(project.version).to eq(1)
    end

    it "assigns the project creator correctly" do
      expect(project.creator_id).to eq(user.id)
    end

    it "generates the reference number correctly" do
      expect(project.reference_number).to start_with reference_number
    end
  end

  describe "#create_project" do
    it "creates a new project and saves to the database" do
      p = nil
      expect { p = subject.create_project }.to change(PafsCore::Project, :count).by(1)

      expect(p).to be_a PafsCore::Project
      expect(p.reference_number).not_to be_nil
      expect(p.version).to eq(1)
      expect(p.creator_id).to eq(user.id)
    end
  end

  describe "#find_project" do
    before do
      @project = subject.create_project
    end

    it "finds a project in the database by reference number" do
      expect(subject.find_project(@project.to_param)).to eq(@project)
    end

    it "raises ActiveRecord::RecordNotFound for an invalid reference_number" do
      expect { subject.find_project("123") }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#all_projects_for" do
    let(:country) { create(:country, :with_full_hierarchy) }
    let(:ea_area_1) { country.children.first }
    let(:ea_area_2) { country.children.second }
    let(:pso_area_1) { ea_area_1.children.first }
    let(:pso_area_2) { ea_area_1.children.second }
    let(:pso_area_3) { ea_area_2.children.first }
    let(:rma_area_1) { pso_area_1.children.first }
    let(:rma_area_2) { pso_area_1.children.second }
    let(:rma_area_3) { pso_area_2.children.first }
    let(:rma_area_4) { pso_area_3.children.first }

    context "with a country" do
      it "sees the correct number of projects" do
        expect(subject.all_projects_for(country).size).to eq(8)
      end
    end

    context "with an EA area" do
      it "sees the correct number of projects" do
        expect(subject.all_projects_for(ea_area_1).size).to eq(4)
      end

      it "does not see another EA area's projects" do
        expect(subject.all_projects_for(ea_area_1)).not_to include(subject.all_projects_for(ea_area_2))
      end

      it "does not see shared projects from outside the EA area" do
        project = rma_area_4.projects.first
        rma_area_1.area_projects.create(project_id: project.id)

        expect(subject.all_projects_for(ea_area_1)).not_to include(project)
      end
    end

    context "with a PSO area" do
      it "sees the correct number of projects" do
        expect(subject.all_projects_for(pso_area_1).size).to eq(2)
      end

      it "does not see another PSO area's projects" do
        expect(subject.all_projects_for(pso_area_1)).not_to include(subject.all_projects_for(pso_area_2))
      end

      it "does not see shared projects from outside the PSO area" do
        project = rma_area_3.projects.first
        rma_area_1.area_projects.create(project_id: project.id)

        expect(subject.all_projects_for(pso_area_1)).not_to include(project)
      end
    end

    context "with an RMA area" do
      it "sees the correct number of projects" do
        expect(subject.all_projects_for(rma_area_1).size).to eq(1)
      end

      it "does not see another RMA area's projects" do
        expect(subject.all_projects_for(rma_area_1)).not_to include(subject.all_projects_for(rma_area_2))
      end

      it "sees another RMA's shared project" do
        project = rma_area_2.projects.first
        rma_area_1.area_projects.create(project_id: project.id)

        expect(subject.all_projects_for(rma_area_1)).to include(project)
      end
    end
  end

  describe "#area_ids_for_user" do
    let(:country) { create(:country, :with_full_hierarchy) }
    let(:ea_area_1) { country.children.first }
    let(:ea_area_2) { country.children.second }
    let(:pso_area_1) { ea_area_1.children.first }
    let(:pso_area_2) { ea_area_1.children.second }
    let(:pso_area_3) { ea_area_2.children.first }
    let(:pso_area_4) { ea_area_2.children.second }
    let(:rma_area_1) { pso_area_1.children.first }
    let(:rma_area_2) { pso_area_1.children.second }
    let(:rma_area_3) { pso_area_2.children.first }
    let(:rma_area_4) { pso_area_2.children.second }
    let(:rma_area_5) { pso_area_3.children.first }
    let(:rma_area_6) { pso_area_3.children.second }
    let(:rma_area_7) { pso_area_4.children.first }
    let(:rma_area_8) { pso_area_4.children.second }

    context "with a country" do
      it "returns the area :ids in my tree" do
        user.user_areas.first.update(area_id: country.id)
        user.touch
        areas = [country.id,
                 ea_area_1.id, ea_area_2.id,
                 pso_area_1.id, pso_area_2.id, pso_area_3.id, pso_area_4.id,
                 rma_area_1.id, rma_area_2.id, rma_area_3.id, rma_area_4.id,
                 rma_area_5.id, rma_area_6.id, rma_area_7.id, rma_area_8.id]

        expect(subject.area_ids_for_user(user).sort).to eq areas.sort
      end
    end

    context "with an EA area" do
      it "returns the area :ids in my sub-tree" do
        user.user_areas.first.update(area_id: ea_area_1.id)
        user.touch
        areas = [ea_area_1.id,
                 pso_area_1.id, pso_area_2.id,
                 rma_area_1.id, rma_area_2.id, rma_area_3.id, rma_area_4.id]
        expect(subject.area_ids_for_user(user).sort).to eq areas.sort
      end
    end

    context "with a PSO area" do
      it "returns the area :ids in my sub-tree" do
        user.user_areas.first.update(area_id: pso_area_1.id)
        user.touch
        areas = [pso_area_1.id,
                 rma_area_1.id, rma_area_2.id]
        expect(subject.area_ids_for_user(user).sort).to eq areas.sort
      end
    end

    context "with an RMA area" do
      it "returns the area :ids in my sub-tree" do
        user.user_areas.first.update(area_id: rma_area_1.id)
        user.touch
        areas = [rma_area_1.id]
        expect(subject.area_ids_for_user(user)).to eq areas
      end
    end
  end

  describe ".generate_reference_number" do
    it "returns a reference number in the correct format" do
      PafsCore::RFCC_CODES.each do |rfcc_code|
        ref = described_class.generate_reference_number(rfcc_code)
        expect(ref).to match %r{\A(AC|AE|AN|NO|NW|SN|SO|SW|TH|TR|TS|WX|YO)C501E/\d{3}A/\d{3}A\z}
      end
    end
  end
end
