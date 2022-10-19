# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::DevelopmentFileStorageService do
  let(:src_file) { "/tmp/dev_file_storage_service.tmp" }
  let(:dst_file) { "1-2-3-4/1/file.xls" }
  let(:dst_path) { subject.send(:file_path, dst_file) }

  after do
    FileUtils.rm_f(src_file)
    FileUtils.rm_f(dst_path)
  end

  describe "#upload" do
    before do
      FileUtils.touch(src_file)
    end

    it "copies the file to the Rails tmp directory" do
      expect { subject.upload(src_file, dst_file) }.not_to raise_error
      expect(File.exist?(dst_path)).to be true
    end

    context "when the file cannot be accessed" do
      it "raises an error" do
        expect { subject.upload("missing.txt", dst_path) }
          .to raise_error PafsCore::FileNotFoundError
      end
    end
  end

  describe "#download" do
    before do
      FileUtils.mkdir_p(File.dirname(dst_path))
      FileUtils.touch(dst_path)
    end

    context "with a valid source file key" do
      it "gets the requested file from storage" do
        expect { subject.download(dst_file, src_file) }.not_to raise_error
        expect(File.exist?(src_file)).to be true
      end
    end

    context "with an invalid source file key" do
      it "raises an error" do
        expect { subject.download("not_there", dst_file) }.to raise_error PafsCore::FileNotFoundError
      end
    end
  end

  describe "#delete" do
    before do
      FileUtils.mkdir_p(File.dirname(dst_path))
      FileUtils.touch(dst_path)
    end

    it "deletes the requested file from storage" do
      expect { subject.delete(dst_file) }.not_to raise_error
      expect(File.exist?(dst_path)).to be false
    end

    context "when the file cannot be accessed" do
      it "raises an error" do
        expect { subject.delete("missing.txt") }
          .to raise_error PafsCore::FileNotFoundError
      end
    end
  end
end
