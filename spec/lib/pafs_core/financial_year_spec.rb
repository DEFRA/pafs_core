# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PafsCore::FinancialYear" do

  describe "#current_financial_year" do
    let(:step) { build(:financial_year_step) }
    let(:current_calendar_year) { Time.zone.today.year }

    context "when the current date is in March" do
      before { Timecop.freeze(Date.new(current_calendar_year, 3, 31)) }

      it { expect(step.current_financial_year).to eq current_calendar_year - 1 }
    end

    context "when the current date is in April" do
      before { Timecop.freeze(Date.new(current_calendar_year, 4, 1)) }

      it { expect(step.current_financial_year).to eq current_calendar_year }
    end
  end
end
