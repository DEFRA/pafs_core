# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::AreaDownloadService do

  subject(:service) { described_class.new(user) }

  let(:user) { create(:user) }
  let(:area) { create(:rma_area) }

  before do
    PafsCore::UserArea.create(user: user, area: area, primary: true)
    area.create_area_download
  end

  describe "#can_generate_documentation?" do

    context "with no previous generation request" do
      it "returns true" do
        expect(service.can_generate_documentation?).to be true
      end
    end

    context "with a previous generation request and generation status 'failed'" do
      before do
        info = area.create_area_download
        info.documentation_state.generate!
        info.documentation_state.error!
        info.save!
      end

      it "returns true" do
        expect(service.can_generate_documentation?).to be true
      end
    end

    context "with a previous generation request and generation status 'generating'" do
      before do
        info = area.create_area_download
        info.documentation_state.generate!
        info.save!
      end

      # This previously returned false to prevent duplicate generation jobs, but that caused issues
      # with the status stuck at "generating" after an error. Currently allowing job submission in all cases.
      it "returns true" do
        expect(service.can_generate_documentation?).to be true
      end
    end
  end

  describe "#generate_downloads" do
    before { allow(PafsCore::GenerateAreaProgrammeJob).to receive(:perform_later) }

    it "submits a generation job" do
      service.generate_downloads

      expect(PafsCore::GenerateAreaProgrammeJob).to have_received(:perform_later)
    end
  end
end
