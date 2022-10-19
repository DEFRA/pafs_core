# frozen_string_literal: true

module PafsCore
  module DataMigration
    class ExportToPol
      def self.perform
        new.tap(&:perform)
      end

      attr_reader :results

      def initialize
        @results = []
      end

      def ids
        @ids ||= Rails.root.join("ids.txt").readlines.map(&:strip)
      end

      def projects
        @projects ||= PafsCore::Project.where(reference_number: ids)
      end

      def perform
        projects.find_each do |project|

          submission = PafsCore::Pol::Submission.new(project)
          submission.perform

          results << {
            id: project.reference_number,
            status: submission.status,
            response: submission.response
          }

          if submission.success?
            puts "[OK] #{project.reference_number}"
          else
            puts "[ERROR] #{project.reference_number}"
          end
        rescue StandardError => e
          puts "[ERROR] #{project.reference_number}"
          results << {
            id: project.reference_number,
            exception: e
          }

        end

        Rails.root.join("results.txt").write(results.inspect)
        puts results.inspect
      end
    end
  end
end
