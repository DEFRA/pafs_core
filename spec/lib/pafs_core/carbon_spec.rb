# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::Carbon do
  subject { test_class.new(project) }

  let(:test_class) do
    Class.new do
      include PafsCore::Carbon

      attr_accessor :project

      def initialize(project)
        @project = project
      end
    end
  end
  let(:project) { create(:project) }

  describe "#carbon_required_information_present?" do
    let(:validation_presenter) { instance_double(PafsCore::ValidationPresenter) }

    before do
      allow(PafsCore::ValidationPresenter).to receive(:new).with(project).and_return(validation_presenter)
      project.start_construction_month = 6
      project.start_construction_year = 2024
      project.ready_for_service_month = 8
      project.ready_for_service_year = 2025
      allow(validation_presenter).to receive(:funding_sources_complete?).and_return(true)
    end

    context "when all required information is present" do
      it { expect(subject).to be_carbon_required_information_present }
    end

    context "when start_construction_month is missing" do
      before do
        project.start_construction_month = nil
      end

      it { expect(subject).not_to be_carbon_required_information_present }
    end

    context "when start_construction_year is missing" do
      before do
        project.start_construction_year = nil
      end

      it { expect(subject).not_to be_carbon_required_information_present }
    end

    context "when ready_for_service_month is missing" do
      before do
        project.ready_for_service_month = nil
      end

      it { expect(subject).not_to be_carbon_required_information_present }
    end

    context "when ready_for_service_year is missing" do
      before do
        project.ready_for_service_year = nil
      end

      it { expect(subject).not_to be_carbon_required_information_present }
    end

    context "when funding sources are not complete" do
      before do
        allow(validation_presenter).to receive(:funding_sources_complete?).and_return(false)
      end

      it { expect(subject).not_to be_carbon_required_information_present }
    end
  end
end
