# frozen_string_literal: true

require "rails_helper"

module PafsCore
  RSpec.describe PafsCore::ApplicationHelper do
    form_instance = nil
    let(:project) { build(:project_name_step, name: nil) }
    let(:pafs_form) { helper.pafs_form_for(project.step, url: pafs_core.projects_path) {} }

    before do
      helper.pafs_form_for(project, url: pafs_core.projects_path) { |f| form_instance = f }
    end

    describe "#pafs_form_for" do
      it "invokes form_for" do
        allow(helper).to receive(:form_for)

        helper.pafs_form_for(project, url: pafs_core.projects_path) {}

        expect(helper).to have_received(:form_for)
      end

      it "wraps the form in a div with the class 'pafs_form'" do
        result = helper.pafs_form_for(project, url: pafs_core.projects_path) {}

        expect(result).to include "<div class=\"pafs_form\"><form"
        expect(result).to include "</form></div>"
      end
    end

    describe "#form_group" do
      context "when the project has no errors" do
        before do
          project.name = "My project"
          project.valid?
        end

        it "outputs a div with the classes 'form-group' and 'no-error'" do
          output = form_group(project, project.step, "wigwam")
          expect(output).to have_css("div.govuk-form-group.no-error")
        end
      end

      context "when the project has errors" do
        before { project.valid? }

        it "outputs a div with the classes 'form-group' and 'govuk-form-group--error'" do
          output = form_group(project, project.step, :name)
          expect(output).to have_css("div.govuk-form-group.govuk-form-group--error")
        end
      end

      it "uses the name param to generate an id attribute" do
        output = form_group(project, project.step, "wigwam")
        expect(output).to have_css("div##{project.step.to_s.dasherize}-wigwam")
      end

      it "yields to a block for the div content" do
        output = form_group(project, project.step, "wigwam") { "<p>Div content</p>".html_safe }
        expect(output).to have_css("div.govuk-form-group p", text: "Div content")
      end
    end

    describe "#error_message" do
      let(:project) { build(:project_name_step) }
      let(:output) { helper.error_message(project, "foo", :name) }

      context "when the attribute has errors" do
        before do
          project.name = nil
          project.valid?
        end

        it "outputs the error messages" do
          project.errors.full_messages_for(:name).each do |msg|
            msg = msg.split("^")[1] if msg =~ /\^/
            expect(output).to have_css("p.govuk-error-message", text: msg)
          end
        end
      end
    end

  end
end
