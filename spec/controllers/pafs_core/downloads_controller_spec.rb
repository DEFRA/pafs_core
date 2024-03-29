# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::DownloadsController do
  routes { PafsCore::Engine.routes }

  before do
    @user = create(:user)
    @country = create(:country, :with_full_hierarchy)
    @area = PafsCore::Area.rma_areas.last
    @user.user_areas.create(area_id: @area.id, primary: true)
    # @project = PafsCore::Project.last
    @project = create(:full_project)
    @project.area_projects.create(area_id: @area.id)
    allow(subject).to receive(:current_resource) { @user }
  end

  describe "GET index" do
    it "renders the index template for html responses" do
      get :index, params: { id: @project.to_param }
      expect(response).to render_template("index")
    end
  end

  describe "GET proposal" do
    it "renders an excel spreadsheet for xlsx requests" do
      get :proposal, params: { id: @project.to_param }, format: :xlsx
      expect(response.headers["Content-Type"]).to eq("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    end

    it "renders a csv for csv requests" do
      get :proposal, params: { id: @project.to_param }, format: :csv
      expect(response.headers["Content-Type"]).to eq("text/csv")
    end
  end

  describe "GET funding_calculator" do
    context "with a file has been stored previously" do
      let(:navigator) { double("navigator") }
      let(:step) { double("funding_calculator_step") }
      let(:data) { "This is the file data" }
      let(:filename) { "my_upload.xlsx" }
      let(:content_type) { "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" }
      let(:download_filename) do
        "#{@project.reference_number.parameterize.upcase}_PFcalculator.xlsx"
      end

      it "sends the file to the client" do
        expect(controller).to receive(:navigator) { navigator }
        expect(navigator).to receive(:find)
          .with(@project.to_param) { @project }

        expect(controller).to receive(:fetch_funding_calculator_for).with(@project) do
          controller.head 200
        end

        get :funding_calculator, params: { id: @project.to_param, step: "funding_calculator" }
      end
    end
  end

  describe "GET delete_funding_calculator" do
    context "with a file has been stored previously" do
      let(:navigator) { double("navigator") }
      let(:filename) { "my_upload.xls" }
      let(:content_type) { "text/plain" }

      it "deletes the funding calculator" do
        expect(controller).to receive(:navigator) { navigator }
        expect(navigator).to receive(:find)
          .with(@project.to_param) { @project }

        expect(controller).to receive(:delete_funding_calculator_for).with(@project)

        get :delete_funding_calculator, params: { id: @project.to_param }
      end
    end
  end

  describe "GET benefit_area" do
    context "with a file has been stored previously" do
      let(:navigator) { double("navigator") }
      let(:step) { double("benefit_area_file_summary_step") }
      let(:data) { "This is the file data" }
      let(:filename) { "my_upload.jpg" }
      let(:content_type) { Mime[:jpeg].to_s }
      let(:download_filename) do
        "#{@project.reference_number.parameterize.upcase}_benefit_area.jpg"
      end

      it "sends the file to the client" do
        expect(controller).to receive(:navigator) { navigator }
        expect(navigator).to receive(:find)
          .with(@project.to_param) { @project }

        expect(controller).to receive(:fetch_benefit_area_file_for).with(@project) { controller.head 200 }

        get :benefit_area, params: { id: @project.to_param }
      end
    end
  end

  describe "GET delete_benefit_area" do
    context "with a file has been stored previously" do
      let(:navigator) { double("navigator") }
      let(:step) { double("benefit_area_file_summary_step") }
      let(:filename) { "my_upload.xls" }
      let(:content_type) { "text/plain" }

      it "deletes the funding benefit area file" do
        expect(controller).to receive(:navigator) { navigator }
        expect(navigator).to receive(:find)
          .with(@project.to_param) { @project }

        expect(controller).to receive(:delete_benefit_area_file_for).with(@project)

        get :delete_benefit_area, params: { id: @project.to_param }
      end
    end
  end

  describe "GET moderation" do
    context "when the project is urgent" do
      let(:navigator) { double("navigator") }
      let(:presenter) { double("moderation_presenter") }
      let(:filename) { "moderation.txt" }
      let(:data) { "This is the file data" }
      let(:content_type) { "text/plain; charset=utf-8" }

      it "sends the file to the client" do
        expect(controller).to receive(:navigator) { navigator }
        expect(navigator).to receive(:find)
          .with(@project.to_param) { @project }

        expect(controller).to receive(:generate_moderation_for).with(@project) { controller.head 200 }

        get :moderation, params: { id: @project.to_param }
      end
    end
  end
end
