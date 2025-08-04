# frozen_string_literal: true

RSpec.shared_examples "updates project attributes" do |step, attribute, negatives_allowed = false, only_integers = false|

  let(:valid_params) do
    value = only_integers ? Faker::Number.number : Faker::Number.decimal(l_digits: 3, r_digits: 2)
    ActionController::Parameters.new(
      { step => { attribute => value } }
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

  unless negatives_allowed
    context "when params are invalid" do
      it "returns false" do
        expect(subject.update(invalid_params)).to be_falsey
      end

      it "does not update project attribute" do
        expect { subject.update(invalid_params) }.not_to(change { subject.project.reload.send(attribute) })
      end

      it "adds validation errors" do
        subject.update(invalid_params)
        expect(subject.errors[attribute]).to include(I18n.t("activemodel.errors.models.pafs_core/#{step}.attributes.#{attribute}.greater_than_or_equal_to"))
      end
    end
  end

  context "when #{attribute} is blank" do
    before do
      subject.project.send("#{attribute}=", Faker::Number.number)
      subject.project.send("save")
    end

    it "saves the blank value successfully" do
      expect { subject.update(blank_params) }.to change { subject.project.reload.send(attribute) }.to(nil)
    end

    it "returns true" do
      expect(subject.update(blank_params)).to be true
    end
  end

end
