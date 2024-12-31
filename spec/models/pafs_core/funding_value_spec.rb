# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::FundingValue do
  let(:project) do
    create(
      :project,
      internal_drainage_boards: true,
      fcerm_gia: true,
      local_levy: true,
      not_yet_identified: true
    )
  end

  describe "attributes" do
    subject { create(:funding_value, project:) }

    it { is_expected.to validate_numericality_of(:fcerm_gia).allow_nil }
    it { is_expected.to validate_numericality_of(:local_levy).allow_nil }
    it { is_expected.to validate_numericality_of(:internal_drainage_boards).allow_nil }
    it { is_expected.to validate_numericality_of(:not_yet_identified).allow_nil }
  end

  describe ".previous_years" do
    before do
      @values = create(:funding_value, :previous_year, project: project)
    end

    it "returns records with :financial_year set to -1" do
      records = described_class.previous_years
      expect(records.first).to eq @values
    end
  end

  describe ".to_financial_year" do
    before do
      @values = [
        create(:funding_value, :previous_year, project: project),
        create(:funding_value, project: project, financial_year: 2017),
        create(:funding_value, project: project, financial_year: 2018),
        create(:funding_value, project: project, financial_year: 2019)
      ]
    end

    it "returns records upto and including the specified year" do
      records = described_class.to_financial_year(2018)
      expect(records.count).to eq 3
      expect(records).to include(*@values[0...-1])
    end
  end

  describe "saving" do
    subject do
      build(
        :funding_value,
        project: project,
        fcerm_gia: fcerm_gia_amount,
        local_levy: local_levy_amount,
        internal_drainage_boards: internal_drainage_boards_amount,
        not_yet_identified: not_yet_identified_amount,
        asset_replacement_allowance: asset_replacement_allowance_amount,
        environment_statutory_funding: environment_statutory_funding_amount
      )
    end

    let(:fcerm_gia_amount) { Faker::Number.number(digits: 7) }
    let(:local_levy_amount) { Faker::Number.number(digits: 7) }
    let(:internal_drainage_boards_amount) { Faker::Number.number(digits: 4) }
    let(:not_yet_identified_amount) { Faker::Number.number(digits: 4) }

    let(:base_funding_total) { fcerm_gia_amount + local_levy_amount + internal_drainage_boards_amount + not_yet_identified_amount }
    let(:additional_fcerm_gia_funding_total) { asset_replacement_allowance_amount + environment_statutory_funding_amount }

    context "without additional fcerm_gia funding sources" do
      let(:asset_replacement_allowance_amount) { nil }
      let(:environment_statutory_funding_amount) { nil }

      it "calculates the total" do
        expect { subject.save }.to change(subject, :total).to(base_funding_total)
      end
    end

    context "with additional fcerm_gia funding sources" do
      let(:asset_replacement_allowance_amount) { Faker::Number.number(digits: 6) }
      let(:environment_statutory_funding_amount) { Faker::Number.number(digits: 6) }

      before do
        project.asset_replacement_allowance = true
        project.environment_statutory_funding = true
      end

      it "calculates the total" do
        expect { subject.save }.to change(subject, :total).to(base_funding_total + additional_fcerm_gia_funding_total)
      end
    end
  end
end
