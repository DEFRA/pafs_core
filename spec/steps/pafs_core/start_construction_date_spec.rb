# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::StartConstructionDateStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:start_construction_date_step) }

    it_behaves_like "a project step"
  end

  describe "#update" do
    let(:project) {
      FactoryGirl.create(
        :project,
        award_contract_month: 1,
        award_contract_year: 2012
      )
    }

    subject { FactoryGirl.create(:start_construction_date_step, project: project) }
    let(:params) {
      HashWithIndifferentAccess.new({
        start_construction_date_step: {
          start_construction_case_year: "2020",
          start_construction_month: "1"
        }
      })
    }

    let(:invalid_month_params) {
      HashWithIndifferentAccess.new({
        start_construction_date_step: {
          start_construction_month: "83",
          start_construction_year: "2020"
        }
      })
    }

    let(:invalid_year_params) {
      HashWithIndifferentAccess.new({
        start_construction_date_step: {
          start_construction_month: "12",
          start_construction_year: "1999"
        }
      })
    }

    let(:invalid_date_params) {
      HashWithIndifferentAccess.new({
        start_construction_date_step: {
          start_construction_month: "12",
          start_construction_year: "2011"
        }
      })
    }

    it "saves the start construction fields when valid" do
      [:start_construction_month, :start_construction_year].each do |attr|
        new_val = subject.send(attr) + 1
        expect(subject.update({start_construction_date_step: { attr => new_val }})).to be true
        expect(subject.send(attr)).to eq new_val
      end
    end

    it "returns false when validation fails" do
      expect(subject.update(invalid_month_params)).to eq false
      expect(subject.update(invalid_year_params)).to eq false
      expect(subject.update(invalid_date_params)).to eq false
    end
  end
end
