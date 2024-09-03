# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ProjectNameStep, type: :model do
  describe "#update" do
    subject(:project_name_step) { create(:project_name_step) }

    let(:valid_params) { ActionController::Parameters.new({ project_name_step: { name: "Wigwam waste water" } }) }
    let(:blank_name_params) { ActionController::Parameters.new({ project_name_step: { name: nil } }) }
    let(:error_message) { "The project name must only contain letters, underscores, hyphens and numbers" }

    it_behaves_like "a project step"

    context "when name is valid" do
      it "returns true and saves the name" do
        expect(project_name_step.name).not_to eq "Wigwam waste water"
        expect(project_name_step.update(valid_params)).to be true
        expect(project_name_step.name).to eq "Wigwam waste water"
      end
    end

    context "when name is blank" do
      it "returns false and sets the correct error message" do
        expect(project_name_step.update(blank_name_params)).to be false
        expect(project_name_step.errors[:name].first).to eq("Tell us the project name")
      end
    end

    context "when name has an invalid format" do
      invalid_names = {
        "slash" => "Invalid/Name",
        "backslash" => "Invalid\\Name",
        "ampersand" => "Invalid&Name",
        "at symbol" => "Invalid@Name",
        "hash symbol" => "Invalid#Name"
      }

      invalid_names.each do |description, name|
        it "returns false and sets the correct error message for #{description} character" do
          project_name_step.name = name
          expect(project_name_step).not_to be_valid
          expect(project_name_step.errors[:name].first).to eq(error_message)
        end
      end
    end

    context "when name already exists" do
      let!(:existing_project) { create(:project_name_step, name: "Unique Project Name") }
      let(:duplicate_name_params) { ActionController::Parameters.new({ project_name_step: { name: "Unique Project Name" } }) }

      it "returns false and sets the uniqueness error message" do
        project_name_step.name = "Different Name"
        expect(project_name_step.update(duplicate_name_params)).to be false
        expect(project_name_step.errors[:name].join).to eq("The project name already exists. Your project must have a unique name.")
      end
    end
  end
end
