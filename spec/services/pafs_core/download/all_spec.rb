# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::Download::All, type: :model do
  let(:download) { described_class.new }

  describe "#remote_file_url" do
    context "when the URL can be generated" do
      before { allow(download).to receive(:expiring_url_for).and_return("http://example.com/all.xlsx") }

      it "returns the URL" do
        expect(download.remote_file_url).to eq("http://example.com/all.xlsx")
      end
    end

    context "when the URL cannot be generated" do
      before { allow(download).to receive(:expiring_url_for).and_raise(StandardError) }

      it "logs a warning" do
        allow(Rails.logger).to receive(:warn)
        download.remote_file_url
        expect(Rails.logger).to have_received(:warn).with(/Error getting URL for download/)
      end

      it "notifies Airbrake" do
        allow(Airbrake).to receive(:notify)
        download.remote_file_url
        expect(Airbrake).to have_received(:notify).with(an_instance_of(StandardError), message: "Error getting URL for download")
      end
    end
  end

  describe "#projects" do
    let!(:project1) { create(:project, :rma_area, :submitted) }
    let!(:project2) { create(:project, :rma_area, :archived) }
    let!(:project3) { create(:project, :rma_area, :draft) }
    let!(:project4) { create(:project, :rma_area, :completed) }

    context "when projects can be found" do
      it "returns projects in all states except :archived" do
        expect(download.projects).to contain_exactly(project1, project3, project4)
      end

      it "does not include :archived project" do
        expect(download.projects).not_to include(project2)
      end

      it "logs a warning" do
        allow(Rails.logger).to receive(:warn)
        download.projects
        expect(Rails.logger).to have_received(:warn).with(/Found \d+ projects for download/)
      end
    end

    context "when projects cannot be found" do
      before { allow(PafsCore::Project).to receive(:joins).and_raise(StandardError) }

      it "logs a warning" do
        allow(Rails.logger).to receive(:warn)
        download.projects
        expect(Rails.logger).to have_received(:warn).with(/Error finding projects for download/)
      end

      it "notifies Airbrake" do
        allow(Airbrake).to receive(:notify)
        download.projects
        expect(Airbrake).to have_received(:notify).with(an_instance_of(StandardError), message: "Error finding projects for download")
      end
    end
  end

  describe "#update_status" do
    let(:meta) { instance_double(PafsCore::Download::Meta, :meta) }

    before { allow(download).to receive(:meta).and_return(meta) }

    it "creates a new meta record with the given data" do
      Timecop.freeze(Date.new(2023, 8, 1))
      allow(meta).to receive(:create)
      download.update_status(foo: "bar")
      expect(meta).to have_received(:create).with({ last_update: Time.now.utc, foo: "bar" })
    end
  end
end
