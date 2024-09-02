# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ProjectNameStep, type: :model do
  describe "attributes" do
    subject { build(:project_name_step) }

    it_behaves_like "a project step"
    it { is_expected.to validate_presence_of(:name).with_message("Tell us the project name") }

    context "when validating name format" do
      valid_names = [
        "Project 123",
        "PROJECT_ABC",
        "project-xyz",
        "Project With Spaces",
        "123_PROJECT_456"
      ]

      invalid_names = [
        "Project/123",
        "Project\\ABC",
        "Project&XYZ",
        "Project@Name",
        "Project#123"
      ]

      valid_names.each do |name|
        it "accepts '#{name}'" do
          subject.name = name
          expect(subject).to be_valid
        end
      end

      invalid_names.each do |name|
        it "rejects '#{name}'" do
          subject.name = name
          expect(subject).not_to be_valid
          expect(subject.errors[:name].join).to eq("The project name must only contain letters, underscores, hyphens and numbers")
        end
      end
    end

    context "when name is not unique" do
      before do
        create(:project_name_step, name: "Existing Project")
      end

      it "returns false when validation fails due to non-unique name" do
        duplicate_params = ActionController::Parameters.new({ project_name_step: { name: "Existing Project" } })
        expect(subject.update(duplicate_params)).to be false
        expect(subject.errors[:name].join).to eq("The project name already exists. Your project must have a unique name.")
      end
    end
  end

  describe "#update" do
    subject { create(:project_name_step) }

    let(:params) { ActionController::Parameters.new({ project_name_step: { name: "Wigwam waste water" } }) }
    let(:error_params) { ActionController::Parameters.new({ project_name_step: { name: nil } }) }
    let(:invalid_format_params) { ActionController::Parameters.new({ project_name_step: { name: "Invalid/Name" } }) }

    it "saves the :name when valid" do
      expect(subject.name).not_to eq "Wigwam waste water"
      expect(subject.update(params)).to be true
      expect(subject.name).to eq "Wigwam waste water"
    end

    it "returns false when validation fails due to blank name" do
      expect(subject.update(error_params)).to be false
    end

    it "returns false when validation fails due to invalid format" do
      expect(subject.update(invalid_format_params)).to be false
      expect(subject.errors[:name].join).to eq("The project name must only contain letters, underscores, hyphens and numbers")
    end
  end
end
