# frozen_string_literal: true

RSpec.shared_examples "does not modify project attributes" do
  describe "#update" do
    let(:params) { ActionController::Parameters.new({ name: "test" }) }

    it "returns true as this is an informational step" do
      expect(subject.update(params)).to be true
    end

    it "does not modify any project attributes" do
      expect { subject.update(params) }.not_to(change { subject.project.attributes })
    end
  end
end
