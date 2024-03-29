# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ReadyForServiceDateStep, type: :model do
  describe "attributes" do
    subject { build(:ready_for_service_date_step) }

    it_behaves_like "a project step"
  end

  describe "#update" do
    subject { create(:ready_for_service_date_step, project: project) }

    let(:project) do
      create(
        :project,
        start_construction_month: 1,
        start_construction_year: 2012
      )
    end
    let(:params) do
      ActionController::Parameters.new({
                                         ready_for_service_date_step: {
                                           ready_for_service_year: 5.years.from_now.year.to_s,
                                           ready_for_service_month: "1"
                                         }
                                       })
    end
    let(:invalid_month_params) do
      ActionController::Parameters.new({
                                         ready_for_service_date_step: { ready_for_service_month: "83", ready_for_service_year: "1999" }
                                       })
    end
    let(:invalid_year_params) do
      ActionController::Parameters.new({
                                         ready_for_service_date_step: { ready_for_service_month: "12", ready_for_service_year: "2000" }
                                       })
    end

    # Commented out as dates can now be in the past ...doesn't reduce the test covergage. let(:invalid_date_params) {
    # ActionController::Parameters.new({
    #  ready_for_service_date_step: { ready_for_service_month: "12", ready_for_service_year: "2013" }
    # })
    # }

    it "saves the start construction fields when valid" do
      %i[ready_for_service_month ready_for_service_year].each do |attr|
        new_val = subject.send(attr) + 1
        params = ActionController::Parameters.new(ready_for_service_date_step: { attr => new_val })

        expect(subject.update(params)).to be true
        expect(subject.send(attr)).to eq new_val
      end
    end

    it "returns false when validation fails" do
      expect(subject.update(invalid_month_params)).to be false
      expect(subject.update(invalid_year_params)).to be false
      # expect(subject.update(invalid_date_params)).to eq false
    end
  end
end
