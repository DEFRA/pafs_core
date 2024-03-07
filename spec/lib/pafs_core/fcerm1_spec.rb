# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::Fcerm1 do
  include described_class

  describe "#column_index" do
    context "when the column code length is 1" do
      it "returns the index of the column code in the A-Z array" do
        expect(column_index("A")).to eq(0)
        expect(column_index("Z")).to eq(25)
      end
    end

    context "when the column code length is more than 1" do
      it "returns the calculated index based on the column code" do
        expect(column_index("AA")).to eq(26)
        expect(column_index("AM")).to eq(38)
        expect(column_index("BO")).to eq(66)
        expect(column_index("BY")).to eq(76)
        expect(column_index("FA")).to eq(156)
        expect(column_index("GO")).to eq(196)
        expect(column_index("KA")).to eq(286)
        expect(column_index("MI")).to eq(346)
        expect(column_index("ND")).to eq(367)
      end
    end
  end
end
