# frozen_string_literal: true

module PafsCore
  module Download
    class All < Base
      FILENAME = {
        production: "area_programme/all.xlsx",
        test: "area_programme/all-test.xlsx",
        development: "area_programme/all-dev.xlsx"
      }.fetch(Rails.env.to_sym)

      def self.exists?
        file_exists?(FILENAME)
      end

      def remote_file_url
        expiring_url_for(FILENAME)
      rescue StandardError => e
        Rails.logger.warn "Error getting URL for download: #{e.inspect}"
        Airbrake.notify(e, message: "Error getting URL for download")
      end

      def projects
        @projects ||= PafsCore::Project.joins(:state)
                                       .joins(:area_projects)
                                       .includes(funding_contributors: :funding_value, area_projects: :area)
        Rails.logger.warn "Found #{@projects.length} projects for download"
        @projects
      rescue StandardError => e
        Rails.logger.warn "Error finding projects for download: #{e.inspect}"
        Airbrake.notify(e, message: "Error finding projects for download")
      end

      def update_status(data)
        meta.create({ last_update: Time.now.utc }.merge(data))
      end

      def meta
        @meta ||= PafsCore::Download::Meta.load("#{FILENAME}.meta")
      end

      def perform
        generate_multi_fcerm1(projects, FILENAME) do |total_records, current_record_index|
          if (current_record_index % 10).zero?
            update_status(status: "pending", current_record: current_record_index, total_records: total_records)
          end
        end

        update_status(status: "complete")
      rescue StandardError => e
        Rails.logger.error "Download all projects failed: #{e.inspect}"
        Airbrake.notify(e, message: "Download all projects failed")
        update_status(status: "failed", exception: e.inspect)
      end
    end
  end
end
