# frozen_string_literal: true

RSpec.shared_examples "validates numericality" do |_step, field, negatives_allowed: false, blanks_allowed: true|
  context "when #{field} is present" do
    it "validates numericality with non-negative values" do
      subject.send("#{field}=", 0)
      expect(subject).to be_valid

      subject.send("#{field}=", 100.50)
      expect(subject).to be_valid

      subject.send("#{field}=", 1000)
      expect(subject).to be_valid
    end

    it "allows decimal values" do
      subject.send("#{field}=", 123.45)
      expect(subject).to be_valid
    end

    unless negatives_allowed
      it "rejects negative values" do
        subject.send("#{field}=", -1)
        expect(subject).not_to be_valid
        expect(subject.errors[field]).to be_present
      end
    end
  end

  context "when #{field} is blank" do
    if blanks_allowed
      it "does not validate numericality" do
        subject.send("#{field}=", nil)
        expect(subject).to be_valid

        subject.send("#{field}=", "")
        expect(subject).to be_valid
      end
    else
      it "rejects blank values" do
        subject.send("#{field}=", nil)
        expect(subject).not_to be_valid
        expect(subject.errors[field]).to be_present
      end
    end
  end
end
