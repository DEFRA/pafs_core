# frozen_string_literal: true

RSpec.shared_examples "validates numericality" do |field|
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

    it "rejects negative values" do
      subject.send("#{field}=", -1)
      expect(subject).not_to be_valid
      expect(subject.errors[field].count).to be > 0
    end
  end

  context "when #{field} is blank" do
    it "does not validate numericality" do
      subject.send("#{field}=", nil)
      expect(subject).to be_valid

      subject.send("#{field}=", "")
      expect(subject).to be_valid
    end
  end
end
