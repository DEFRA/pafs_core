# frozen_string_literal: true

require "roo"

module PafsCore
  class FundingCalculatorStep < BasicStep
    include PafsCore::FileStorage
    include PafsCore::FileTypes
    include PafsCore::FundingCalculatorVersion

    delegate :funding_calculator_file_name, :funding_calculator_file_name=,
             :funding_calculator_content_type, :funding_calculator_content_type=,
             :funding_calculator_file_size, :funding_calculator_file_size=,
             :funding_calculator_updated_at, :funding_calculator_updated_at=,
             :storage_path,
             to: :project

    attr_reader :funding_calculator
    attr_accessor :virus_info, :uploaded_file, :expected_version

    validate :virus_free_funding_calculator_present
    validate :validate_calculator_sheet_present
    validate :validate_calculator_version

    def update(params)
      return true if params.fetch(:commit, nil) == "Continue"

      uploaded_file = step_params(params).fetch(:funding_calculator, nil)

      if uploaded_file
        return false unless filetype_valid?(uploaded_file)

        begin
          old_file = funding_calculator_file_name
          # virus check and upload to S3
          filename = File.basename(uploaded_file.original_filename)
          dest_file = File.join(storage_path, filename)
          storage.upload(uploaded_file.tempfile.path, dest_file)

          begin
            PafsCore::CalculatorParser.parse(uploaded_file, project)
          rescue StandardError
            errors.add(
              :funding_calculator,
              "The file could not be processed. Please ensure you're using the correct " \
              "Partnership Funding Calculator version."
            )
            storage.delete(dest_file)
            return false
          end

          if old_file && old_file != filename
            # aws doesn't raise an error if it cannot find the key when deleting
            storage.delete(File.join(storage_path, old_file))
          end

          self.uploaded_file = uploaded_file.tempfile
          self.expected_version = step_params(params).fetch(:expected_version, nil)

          self.funding_calculator_file_name = filename
          self.funding_calculator_content_type = uploaded_file.content_type
          self.funding_calculator_file_size = uploaded_file.size
          self.funding_calculator_updated_at = Time.zone.now
          self.virus_info = nil
        rescue PafsCore::VirusFoundError, PafsCore::VirusScannerError => e
          self.virus_info = e.message
        end
      end

      valid? && project.save
    end

    private

    def step_params(params)
      params
        .require(:funding_calculator_step)
        .permit(:funding_calculator, :expected_version)
    end

    # NOTE: we could probably check the content type of the file but we are
    # expecting a .xslx file to be uploaded
    def filetype_valid?(file)
      return true if valid_funding_calculator_file?(file.original_filename)

      errors.add(:funding_calculator, I18n.t("unsupported_funding_calc_format"))
      false
    end

    def virus_free_funding_calculator_present
      if virus_info.present?
        Rails.logger.error virus_info
        errors.add(:funding_calculator,
                   "The file was rejected because it may contain a virus. Check the file and try again")
      elsif funding_calculator_file_name.blank?
        errors.add(:funding_calculator, "Upload the completed partnership funding calculator .xslx file")
      end
    end

    def calculator
      @calculator ||= ::Roo::Excelx.new(uploaded_file)
    end

    def calculator_sheet_name
      @calculator_sheet_name ||= calculator.sheets.grep(/PF Calculator/i).first
    rescue StandardError
      nil
    end

    def sheet
      @sheet ||= calculator.sheet(calculator_sheet_name)
    end

    def expected_version_name
      {
        v8: "v8 2014",
        v9: "v2 2020"
      }[expected_version.to_sym]
    end

    def validate_calculator_sheet_present
      return if virus_info.present?
      return if calculator_sheet_name.present?

      self.funding_calculator_file_name = ""
      errors.add(:funding_calculator, "Please ensure you upload a valid partnership funding calculator")
    end

    def validate_calculator_version
      return if virus_info.present?
      return if calculator_sheet_name.blank?
      return if calculator_version.to_s == expected_version && calculator_version.present?

      self.funding_calculator_file_name = ""
      errors.add(:funding_calculator, "The uploaded calculator is the incorrect version. " \
                                      "You must submit the #{expected_version_name} calculator.")
    end
  end
end
