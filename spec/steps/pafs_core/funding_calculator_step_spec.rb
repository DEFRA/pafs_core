# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::FundingCalculatorStep, type: :model do
  let(:v8_calculator_file) { Rails.root.join("../fixtures/calculators/v8.xlsx").open }
  let(:v9_calculator_file) { Rails.root.join("../fixtures/calculators/v9.xlsx").open }

  describe "attributes" do
    subject { build(:funding_calculator_step) }

    it_behaves_like "a project step"

    it "validates that a file has been selected" do
      subject.funding_calculator_file_name = nil
      expect(subject.valid?).to be false
      expect(subject.errors[:funding_calculator]).to include "Upload the completed partnership funding calculator .xslx file"
    end

    it "validates that the file passed a virus check" do
      subject.virus_info = "Found a nasty virus"
      expect(subject.valid?).to be false
      expect(subject.errors[:funding_calculator])
        .to include "The file was rejected because it may contain a virus. Check the file and try again"
    end

    it "validates the calculator version when correct" do
      allow(subject).to receive_messages(uploaded_file: v9_calculator_file)

      expect(subject).to be_valid
    end

    it "validates the calculator version" do
      allow(subject).to receive_messages(uploaded_file: v8_calculator_file)

      subject.valid?

      expect(subject.errors[:funding_calculator])
        .to include "The uploaded calculator is the incorrect version. You must submit the v2 2020 calculator."
    end

    context "when a virus is found" do
      it "does not validate the calculator version" do
        allow(subject)
          .to receive(:virus_info)
          .and_return("Some virus")

        expect(Roo::Excelx)
          .not_to receive(:new)

        subject.valid?
      end
    end
  end

  describe "#update" do
    subject { build(:funding_calculator_step) }

    let(:filename) { "new_file.xlsx" }
    let(:content_type) { "text/plain" }
    let(:temp_file) do
      ActionDispatch::Http::UploadedFile.new(tempfile: v9_calculator_file,
                                             filename: filename.dup,
                                             type: content_type)
    end
    let(:params) do
      ActionController::Parameters.new(
        { funding_calculator_step: { funding_calculator: temp_file } }
      )
    end
    let(:empty_params) do
      ActionController::Parameters.new(
        { funding_calculator_step: { funding_calculator_file_name: "placeholder" } }
      )
    end
    let(:continue_params) { { commit: "Continue" } }

    context "when 'Continue' button selected" do
      it "returns true" do
        expect(subject.update(continue_params)).to be true
      end
    end

    context "when a virus free file is selected" do
      let(:storage) { double("storage") }

      before do
        allow(PafsCore::DevelopmentFileStorageService).to receive(:new) { storage }
        allow(storage).to receive(:upload).and_return(true)
        subject.funding_calculator_file_name = nil
      end

      it "uploads the file" do
        expect(subject.update(params)).to be true
      end

      it "saves the file details" do
        subject.update(params)
        expect(subject.funding_calculator_file_name).to eq filename
        expect(subject.funding_calculator_content_type).to eq content_type
        expect(subject.funding_calculator_file_size).to eq v9_calculator_file.size
        expect(subject.funding_calculator_updated_at).to be_within(1.second).of(Time.zone.now)
      end

      context "when an uploaded file already exists" do
        let(:new_file) { "my_file.xlsx" }

        it "deletes the previous file" do
          subject.funding_calculator_file_name = new_file
          expect(storage).to receive(:delete).with(File.join(subject.storage_path, new_file)).and_return(true)
          expect(subject.update(params)).to be true
        end
      end
    end

    context "when a valid file has already been uploaded" do
      it "returns false when no new file is selected" do
        expect(subject.update(empty_params)).to be false
      end
    end

    context "when a virus infected file is selected" do
      let(:storage) { double("storage") }

      before do
        allow(PafsCore::DevelopmentFileStorageService).to receive(:new) { storage }
        allow(storage).to receive(:upload) do
          raise PafsCore::VirusFoundError.new(v8_calculator_file.path, "nAsTyVirus")
        end
      end

      it "does not save the file details" do
        expect { subject.update(params) }.not_to change(subject, :funding_calculator_file_name)
      end

      it "returns false" do
        expect(subject.update(params)).to be false
      end
    end

    context "when a virus scanner issue prevented the file from being scanned" do
      let(:storage) { double("storage") }

      before do
        allow(PafsCore::DevelopmentFileStorageService).to receive(:new) { storage }
        allow(storage).to receive(:upload) do
          raise PafsCore::VirusScannerError, "A problem occurred"
        end
      end

      it "does not save the file details" do
        expect { subject.update(params) }.not_to change(subject, :funding_calculator_file_name)
      end

      it "returns false" do
        expect(subject.update(params)).to be false
      end
    end

    context "when there is an error parsing the calculator file" do
      let(:storage) { double("storage") }

      before do
        allow(PafsCore::DevelopmentFileStorageService).to receive(:new) { storage }
        allow(storage).to receive_messages(upload: true, delete: true)
        allow(PafsCore::CalculatorParser).to receive(:parse).and_raise(StandardError, "Unknown PFC version")
      end

      it "adds an error message" do
        subject.update(params)
        expect(subject.errors[:funding_calculator]).to include(
          "The file could not be processed. Please ensure you're using the correct Partnership Funding Calculator version."
        )
      end

      it "cleans up the uploaded file" do
        expect(storage).to receive(:delete).with(File.join(subject.storage_path, filename))
        subject.update(params)
      end

      it "returns false" do
        expect(subject.update(params)).to be false
      end
    end
  end

  # describe "#download" do
  #   let(:storage) { double("storage") }
  #   subject { build(:funding_calculator_step) }
  #   before(:each) do
  #     @upload_path = File.join(subject.storage_path, subject.funding_calculator_file_name)
  #     expect(PafsCore::FileStorageService).to receive(:new) { storage }
  #   end
  #
  #   context "when an uploaded file exists" do
  #     let(:tmpfile) { double("tmpfile") }
  #     before(:each) do
  #       expect(storage).to receive(:download)
  #       expect(Tempfile).to receive(:new) { tmpfile }
  #       expect(tmpfile).to receive(:path) { "path/to/file.xls" }
  #       expect(tmpfile).to receive(:rewind) { 0 }
  #     end
  #
  #     it "returns a temporary file" do
  #       expect(subject.download).to eq tmpfile
  #     end
  #
  #     context "when a block is given" do
  #       let(:tmpfile_content) { "Wigwam haystack" }
  #       it "passes the temporary file data and details to the block" do
  #         expect(tmpfile).to receive(:read) { tmpfile_content }
  #         expect(tmpfile).to receive(:close!)
  #
  #         expect { |b| subject.download(&b) }.
  #           to yield_with_args(tmpfile_content,
  #                           subject.funding_calculator_file_name,
  #                           subject.funding_calculator_content_type)
  #       end
  #     end
  #   end
  # end

  # describe "#delete_calculator" do
  #   let(:storage) { double("storage") }
  #   subject { build(:funding_calculator_step) }
  #   before(:each) do
  #     expect(PafsCore::FileStorageService).to receive(:new) { storage }
  #   end
  #
  #   context "when an uploaded file exists" do
  #     it "removes the file from storage" do
  #       expect(storage).to receive(:delete)
  #       subject.delete_calculator
  #     end
  #
  #     it "resets the stored file attributes" do
  #       expect(storage).to receive(:delete)
  #       subject.delete_calculator
  #       expect(subject.funding_calculator_file_name).to be_nil
  #       expect(subject.funding_calculator_content_type).to be_nil
  #       expect(subject.funding_calculator_file_size).to be_nil
  #       expect(subject.funding_calculator_updated_at).to be_nil
  #       expect(subject.virus_info).to be_nil
  #     end
  #   end
  # end
end
