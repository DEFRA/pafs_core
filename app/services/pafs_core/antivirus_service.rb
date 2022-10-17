# frozen_string_literal: true

require "clamav/client"
module PafsCore
  class AntivirusService
    attr_reader :user

    def initialize(user = nil)
      # when instantiated from a controller the 'current_user' should
      # be passed in. This will allow us to audit actions etc. down the line.
      @user = user
    end

    def service_available?
      scanner.execute(ClamAV::Commands::PingCommand.new)
    end

    def scan(path)
      # default clamav scan op is SCAN which stops when it finds a virus
      # so you would need to quarantine the file and re-scan until no virii
      # were found
      file = path.to_s

      # this is a file in /tmp with 0600 perms by default
      # need to make it accessible to the virus scanner
      File.chmod(0o644, file) if File.file? file

      results = scanner.execute(ClamAV::Commands::ScanCommand.new(file))
      results.each do |result|

        raise PafsCore::VirusFoundError.new(result.file, result.virus_name) if result.instance_of? ClamAV::VirusResponse

        raise PafsCore::VirusScannerError, result.error_str if result.instance_of? ClamAV::ErrorResponse
      end
      true
    end

    private

    def scanner
      ClamAV::Client.new
    end
  end
end
