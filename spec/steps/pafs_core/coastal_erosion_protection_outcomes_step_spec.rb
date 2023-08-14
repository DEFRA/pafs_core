# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CoastalErosionProtectionOutcomesStep, type: :model do
  before do
    Timecop.freeze(Date.new(2015, 4, 1))

    @project = create(:project)
    @project.project_end_financial_year = 2027
    @project.coastal_erosion = true
    @cepo1 = create(:coastal_erosion_protection_outcomes, financial_year: 2017, project_id: @project.id)
    @cepo2 = create(:coastal_erosion_protection_outcomes, financial_year: 2020, project_id: @project.id)
    @cepo3 = create(:coastal_erosion_protection_outcomes, financial_year: 2030, project_id: @project.id)
    @project.coastal_erosion_protection_outcomes << @cepo1
    @project.coastal_erosion_protection_outcomes << @cepo2
    @project.coastal_erosion_protection_outcomes << @cepo3

    @project.save
  end

  after { Timecop.return }

  describe "attributes" do
    subject { described_class.new @project }

    it_behaves_like "a project step"

    it "validates that value C is smaller than B" do
      subject.coastal_erosion_protection_outcomes.build(financial_year: 2020,
                                                        households_at_reduced_risk: 100,
                                                        households_protected_from_loss_in_next_20_years: 50,
                                                        households_protected_from_loss_in_20_percent_most_deprived: 100)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include
      "The number of households in the 20% most deprived areas (column C) must be lower than or equal to the number of \
      households protected from loss within the next 20 years (column B)."
    end

    it "validates that value B is smaller than A" do
      subject.coastal_erosion_protection_outcomes.build(financial_year: 2020,
                                                        households_at_reduced_risk: 100,
                                                        households_protected_from_loss_in_next_20_years: 200)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include
      "The number of households protected from loss within the next 20 years (column B) must be lower than or equal \
      to the number of households at a reduced risk of coastal erosion (column A)."
    end

    it "validates that there is at least one A value" do
      @project.coastal_erosion_protection_outcomes = []
      @project.save
      subject.coastal_erosion_protection_outcomes.build(financial_year: 2020,
                                                        households_at_reduced_risk: 0)

      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include
      "In the applicable year(s), tell us how many households are at a reduced risk of coastal erosion."
    end

    # rubocop:disable Lint/Void
    it "validates that number of properties is less than or equal to 1 million" do
      subject.coastal_erosion_protection_outcomes.build(financial_year: 2020,
                                                        households_at_reduced_risk: 1_000_001,
                                                        households_protected_from_loss_in_next_20_years: 1_000_001,
                                                        households_protected_from_loss_in_20_percent_most_deprived: 1_000_001,
                                                        non_residential_properties: 1_000_001)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include
      "The number of properties at reduced risk must be less than or equal to 1 million."
      expect(subject.errors.messages[:base]).to include
      "The number of properties protected from loss in the next 20 years must be less than or equal to 1 million."
      expect(subject.errors.messages[:base]).to include
      "The number of properties protected from loss in the 20 percent most deprived must be \
      less than or equal to 1 million."
      expect(subject.errors.messages[:base]).to include
      "The number of non-residential properties protected from loss must be \
      less than or equal to 1 million."
    end
    # rubocop:enable Lint/Void
  end

  describe "#update" do
    subject { described_class.new @project }

    let(:params) do
      ActionController::Parameters.new(
        { coastal_erosion_protection_outcomes_step:
          { coastal_erosion_protection_outcomes_attributes:
            [{ financial_year: 2020,
               households_at_reduced_risk: 2000,
               households_protected_from_loss_in_next_20_years: 1000,
               households_protected_from_loss_in_20_percent_most_deprived: 500,
               non_residential_properties: 1000 }] } }
      )
    end

    let(:error_params) do
      ActionController::Parameters.new(
        { coastal_erosion_protection_outcomes_step:
          { coastal_erosion_protection_outcomes_attributes:
            [{ financial_year: 2020,
               households_at_reduced_risk: 1000,
               households_protected_from_loss_in_next_20_years: 2000,
               households_protected_from_loss_in_20_percent_most_deprived: 5000,
               non_residential_properties: 1000 }] } }
      )
    end

    context "when params are invalid" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not save the changes" do
        expect { subject.update(error_params) }.not_to change { subject.coastal_erosion_protection_outcomes.count }
      end
    end

    context "when params are valid" do
      it "saves the changes" do
        expect { subject.update(params) }.to change { subject.coastal_erosion_protection_outcomes.count }.by(1)
        coastal_erosion_protection_outcome = subject.coastal_erosion_protection_outcomes.last
        expect(coastal_erosion_protection_outcome.financial_year).to eq 2020
        expect(coastal_erosion_protection_outcome.households_at_reduced_risk).to eq 2000
        expect(coastal_erosion_protection_outcome.households_protected_from_loss_in_next_20_years).to eq 1000
        expect(coastal_erosion_protection_outcome.households_protected_from_loss_in_20_percent_most_deprived).to eq 500
        expect(coastal_erosion_protection_outcome.non_residential_properties).to eq 1000
      end

      it "returns true" do
        expect(subject.update(params)).to be true
      end
    end
  end

  describe "#current_coastal_erosion_protection_outcomes" do
    subject { described_class.new @project }
    # subject.project.coastal_erosion_protection_outcomes << [@cepo1, @cepo2, @cepo3]

    it "includes the coastal erosion protection outcomes before the project end financial year" do
      expect(subject.current_coastal_erosion_protection_outcomes).to include(@cepo1, @cepo2)
    end

    it "does not include the coastal erosion protection outcomes after the project end financial year" do
      expect(subject.current_coastal_erosion_protection_outcomes).not_to include(@cepo3)
    end
  end

  describe "#before_view" do
    subject { described_class.new @project }

    it "builds coastal_erosion_protection_outcome records for any missing years" do
      # test start year is 2015
      # project_end_financial_year = 2027
      # values are initially populated for 2017, 2020, 2030
      # so expect placeholders to be added for 2015, 2016, 2018, 2019, and 2021 - 2027
      expect { subject.before_view({}) }.to change { subject.coastal_erosion_protection_outcomes.length }.by(11)
    end
  end
end
