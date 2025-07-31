# frozen_string_literal: true

RSpec.shared_examples "updates project attributes" do |step, attribute|

  let(:valid_params) do
    ActionController::Parameters.new(
      { step => { attribute => Faker::Number.decimal(l_digits: 3, r_digits: 2) } }
    )
  end

  let(:invalid_params) do
    ActionController::Parameters.new(
      { step => { attribute => Faker::Number.negative } }
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
      expect { subject.update(valid_params) }.to change { subject.send(attribute) }.to(valid_params[step][attribute])
    end

    it "returns true" do
      expect(subject.update(valid_params)).to be true
    end
  end

  context "when params are invalid" do
    it "returns false" do
      expect(subject.update(invalid_params)).to be_falsey
    end

    it "does not update project attribute" do
      expect { subject.update(invalid_params) }.not_to(change { subject.project.reload.send(attribute) })
    end

    it "adds validation errors" do
      subject.update(invalid_params)
      expect(subject.errors[attribute]).to include("The value entered can not be negative")
    end
  end

  context "when #{attribute} is blank" do
    it "saves the blank value successfully" do
      subject.project.send("#{attribute}=", Faker::Number.number)
      expect { subject.update(blank_params) }.to change { subject.project.reload.send(attribute) }.to(nil)
    end

    it "returns true" do
      expect(subject.update(blank_params)).to be true
    end
  end

end
