# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::StartOutlineBusinessCaseDateStep, type: :model do
  describe "attributes" do
    subject { build(:start_outline_business_case_date_step) }

    it_behaves_like "a project step"

    it "validates that date have been set" do
      subject.start_outline_business_case_year = nil
      subject.start_outline_business_case_month = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:award_contract])
        .to include "Enter the date you expect to award the project's main contract"
    end

    it "validates that date is in the future" do
      subject.start_outline_business_case_year = 2020
      subject.start_outline_business_case_month = 1
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:start_outline_business_case].first).to eq "You cannot enter a date in the past"
    end
  end

  describe "#update" do
    subject { create(:start_outline_business_case_date_step, start_outline_business_case_year: 2030, start_outline_business_case_month: 1) }

    let(:params) do
      ActionController::Parameters.new({
                                         start_outline_business_case_date_step: {
                                           start_outline_business_case_year: "2030"
                                         }
                                       })
    end

    let(:error_params) do
      ActionController::Parameters.new({
                                         start_outline_business_case_date_step: {
                                           start_outline_business_case_month: "83"
                                         }
                                       })
    end

    it "saves the start outline business case fields when valid" do
      %i[start_outline_business_case_month start_outline_business_case_year].each do |attr|
        new_val = subject.send(attr) + 1
        params = ActionController::Parameters.new(start_outline_business_case_date_step: { attr => new_val })
        expect(subject.update(params)).to be true
        expect(subject.send(attr)).to eq new_val
      end
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to be false
    end
  end
end
