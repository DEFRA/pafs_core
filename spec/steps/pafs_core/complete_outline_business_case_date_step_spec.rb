# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CompleteOutlineBusinessCaseDateStep, type: :model do
  describe "attributes" do
    subject { build(:complete_outline_business_case_date_step) }

    it_behaves_like "a project step"
  end

  describe "#update" do
    subject { create(:complete_outline_business_case_date_step, project: project) }

    let(:project) do
      create(
        :project,
        start_outline_business_case_month: 1,
        start_outline_business_case_year: 2012
      )
    end
    let(:params) do
      ActionController::Parameters.new({
                                         complete_outline_business_case_date_step: {
                                           complete_outline_business_case_case_year: "2020",
                                           complete_outline_business_case_month: "1"
                                         }
                                       })
    end
    let(:invalid_month_params) do
      ActionController::Parameters.new({
                                         complete_outline_business_case_date_step: {
                                           complete_outline_business_case_month: "83",
                                           complete_outline_business_case_year: "2020"
                                         }
                                       })
    end
    let(:invalid_year_params) do
      ActionController::Parameters.new({
                                         complete_outline_business_case_date_step: {
                                           complete_outline_business_case_month: "12",
                                           complete_outline_business_case_year: "1999"
                                         }
                                       })
    end
    let(:invalid_date_params) do
      ActionController::Parameters.new({
                                         complete_outline_business_case_date_step: {
                                           complete_outline_business_case_month: "12",
                                           complete_outline_business_case_year: "2011"
                                         }
                                       })
    end

    it "saves the start outline business case fields when valid" do
      %i[complete_outline_business_case_month complete_outline_business_case_year].each do |attr|
        new_val = subject.send(attr) + 1
        params = ActionController::Parameters.new(complete_outline_business_case_date_step: { attr => new_val })
        expect(subject.update(params)).to be true
        expect(subject.send(attr)).to eq new_val
      end
    end

    it "returns false when validation fails" do
      expect(subject.update(invalid_month_params)).to be false
      expect(subject.update(invalid_year_params)).to be false
      expect(subject.update(invalid_date_params)).to be false
    end
  end
end
