# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CarbonCostOperationStep, type: :model do
  subject { build(:carbon_cost_operation_step) }

  it_behaves_like "a project step"

  describe "validations" do
    context "when carbon_cost_operation is present" do
      it "validates numericality with non-negative values" do
        subject.carbon_cost_operation = 0
        expect(subject).to be_valid

        subject.carbon_cost_operation = 100.50
        expect(subject).to be_valid

        subject.carbon_cost_operation = 1000
        expect(subject).to be_valid
      end

      it "allows decimal values" do
        subject.carbon_cost_operation = 123.45
        expect(subject).to be_valid
      end

      it "rejects negative values" do
        subject.carbon_cost_operation = -1
        expect(subject).not_to be_valid
        expect(subject.errors[:carbon_cost_operation]).to include("The value entered can not be negative")
      end
    end

    context "when carbon_cost_operation is blank" do
      it "does not validate numericality" do
        subject.carbon_cost_operation = nil
        expect(subject).to be_valid

        subject.carbon_cost_operation = ""
        expect(subject).to be_valid
      end
    end
  end

  describe "#update" do
    subject { create(:carbon_cost_operation_step) }

    let(:valid_params) do
      ActionController::Parameters.new({
                                         carbon_cost_operation_step: { carbon_cost_operation: "150.75" }
                                       })
    end

    let(:invalid_params) do
      ActionController::Parameters.new({
                                         carbon_cost_operation_step: { carbon_cost_operation: "-50" }
                                       })
    end

    let(:non_numeric_params) do
      ActionController::Parameters.new({
                                         carbon_cost_operation_step: { carbon_cost_operation: "not_a_number" }
                                       })
    end

    let(:blank_params) do
      ActionController::Parameters.new({
                                         carbon_cost_operation_step: { carbon_cost_operation: "" }
                                       })
    end

    context "when params are valid" do
      it "saves the carbon_cost_operation value" do
        expect(subject.carbon_cost_operation).not_to eq(150.75)
        expect(subject.update(valid_params)).to be true
        expect(subject.carbon_cost_operation).to eq(150.75)
      end

      it "returns true" do
        expect(subject.update(valid_params)).to be true
      end
    end

    context "when params are invalid" do
      it "assigns the invalid value but does not save to the database" do
        original_project_value = subject.project.carbon_cost_operation
        expect(subject.update(invalid_params)).to be false
        # The step assigns the invalid value but database remains unchanged
        expect(subject.carbon_cost_operation).to eq(-50.0)
        subject.project.reload
        expect(subject.project.carbon_cost_operation).to eq(original_project_value)
      end

      it "returns false" do
        expect(subject.update(invalid_params)).to be false
      end

      it "adds validation errors" do
        subject.update(invalid_params)
        expect(subject.errors[:carbon_cost_operation]).to include("The value entered can not be negative")
      end
    end

    context "when carbon_cost_operation is blank" do
      it "saves the blank value successfully" do
        subject.carbon_cost_operation = 100
        expect(subject.update(blank_params)).to be true
        expect(subject.carbon_cost_operation).to be_blank
      end

      it "returns true" do
        expect(subject.update(blank_params)).to be true
      end
    end
  end
end
