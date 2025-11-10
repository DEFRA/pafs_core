# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::Project do
  describe "attributes" do
    subject { create(:project) }

    it { is_expected.to validate_presence_of :reference_number }

    it { is_expected.to validate_presence_of :version }

    it { is_expected.to validate_uniqueness_of(:reference_number).scoped_to :version }

    it "returns a parmeterized :reference_number as a URL slug" do
      expect(subject.to_param).to eq(subject.reference_number.parameterize.upcase)
    end

    context "when validating reference numbers" do
      %w[YOC357I/000A/037A].each do |ref|
        it "accepts #{ref}" do
          subject.reference_number = ref
          expect(subject).to be_valid
        end
      end

      %w[123].each do |ref|
        it "rejects #{ref}" do
          subject.reference_number = ref
          expect(subject).not_to be_valid
          expect(subject.errors[:reference_number].join).to match(/invalid format/)
        end
      end
    end
  end

  describe "#flooding?" do
    subject { create(:project) }

    it "is expected to return true if the project protects against any kind of flooding" do
      subject.reservoir_flooding = true
      expect(subject.flooding?).to be(true)

      subject.reservoir_flooding = false
      subject.fluvial_flooding = true
      expect(subject.flooding?).to be(true)

      subject.fluvial_flooding = false
      subject.groundwater_flooding = true
      expect(subject.flooding?).to be(true)

      subject.groundwater_flooding = false
      subject.tidal_flooding = true
      expect(subject.flooding?).to be(true)

      subject.tidal_flooding = false
      subject.surface_water_flooding = true
      expect(subject.flooding?).to be(true)

      subject.surface_water_flooding = false
      expect(subject.flooding?).not_to be(true)
    end
  end

  describe "#project_protects_households?" do
    it "is expected to return false if the project does not protect households" do
      subject.project_type = "ENV_WITHOUT_HOUSEHOLDS"

      expect(subject.project_protects_households?).to be false
    end

    it "is expected to return true if the project does protect households" do
      project_types = PafsCore::PROJECT_TYPES[0...-1]

      project_types.each do |pt|
        subject.project_type = pt
        expect(subject.project_protects_households?).to be true
      end
    end
  end

  describe "#first_financial_year" do
    let(:project) { create(:project, :with_funding_values) }

    context "when all attributes have the same starting year" do
      it { expect(project.first_financial_year).to eq(2015) }
    end

    context "when the attributes have different starting years" do
      let(:earliest_year) { 2010 }

      before { project.funding_values << build(:funding_value, financial_year: earliest_year) }

      it { expect(project.first_financial_year).to eq earliest_year }
    end
  end

  # Here we don't verify Digest::SHA1 checksum generation; we just test basic behaviour.
  # Checksum value checking will be performed in the projects request specs.
  describe "#carbon_values_calculate_hexdigest" do
    let(:project) { build(:project, :with_carbon_values) }

    it { expect { project.carbon_values_calculate_hexdigest }.not_to raise_error }

    it { expect(project.carbon_values_calculate_hexdigest).to be_a String }

    it { expect(project.carbon_values_calculate_hexdigest).not_to be_empty }
  end

  describe "#carbon_values_update_hexdigest" do
    let(:project) { build(:project, :with_carbon_values) }

    it { expect { project.carbon_values_update_hexdigest }.to change(project, :carbon_values_hexdigest) }
  end
end
