# frozen_string_literal: true

RSpec.shared_examples "updates project attributes" do |step, attribute|

  let(:valid_params) do
    ActionController::Parameters.new(
      { step => { attribute => "150.75" } }
    )
  end

  let(:invalid_params) do
    ActionController::Parameters.new(
      { step => { attribute => "-50" } }
    )
  end

  let(:non_numeric_params) do
    ActionController::Parameters.new(
      { step => { attribute => "not_a_number" } }
    )
  end

  let(:blank_params) do
    ActionController::Parameters.new(
      { step => { attribute => "" } }
    )
  end

  context "when params are valid" do
    it "saves the #{attribute} value" do
      expect(subject.send(attribute)).not_to eq(150.75)
      expect(subject.update(valid_params)).to be true
      expect(subject.send(attribute)).to eq(150.75)
    end

    it "returns true" do
      expect(subject.update(valid_params)).to be true
    end
  end

  context "when params are invalid" do
    it "assigns the invalid value but does not save to the database" do
      original_project_value = subject.project.send(attribute)
      expect(subject.update(invalid_params)).to be false
      # The step assigns the invalid value but database remains unchanged
      expect(subject.send(attribute)).to eq(-50.0)
      subject.project.reload
      expect(subject.project.send(attribute)).to eq(original_project_value)
    end

    it "returns false" do
      expect(subject.update(invalid_params)).to be false
    end

    it "adds validation errors" do
      subject.update(invalid_params)
      expect(subject.errors[attribute]).to include("The value entered can not be negative")
    end
  end

  context "when #{attribute} is blank" do
    it "saves the blank value successfully" do
      subject.send("#{attribute}=", 100)
      expect(subject.update(blank_params)).to be true
      expect(subject.send(attribute)).to be_blank
    end

    it "returns true" do
      expect(subject.update(blank_params)).to be true
    end
  end

end
