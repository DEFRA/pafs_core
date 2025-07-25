# frozen_string_literal: true

module PafsCore
  class FundingContributorsStep < BasicStep
    include PafsCore::FundingSources
    include PafsCore::FundingValues

    def funding_source
      :public_contributions
    end

    def current_funding_contributors
      fc = project.funding_contributors.where(contributor_type: funding_source).order(:id).pluck(:name).uniq
      fc.any? ? fc : [""]
    end

    def funding_contributors_to_delete(params)
      @funding_contributors_to_delete ||= current_funding_contributors -
                                          step_params(params).map { |e| e[:current].strip }
    end

    def delete_removed_contributors(params)
      funding_values.find_each do |fv|
        fc_to_delete = PafsCore::FundingContributor.where(
          funding_value: fv,
          name: funding_contributors_to_delete(params)
        )

        fc_to_delete.destroy_all
      end
    end

    def create_new_contributors(params)
      step_params(params).each do |name|
        funding_values.find_each do |fv|
          current_name = name[:current].strip

          next if current_name.blank?
          next if fv.send(funding_source).where(name: current_name).present?

          fv.send(funding_source).create(name: current_name)
        end
      end
    end

    def update_changed_contributors(params)
      step_params(params).each do |name|
        previous_name = name[:previous].strip
        current_name = name[:current].strip

        next if current_name.blank?
        next if previous_name.blank?
        next if previous_name == current_name

        funding_values.find_each do |fv|
          PafsCore::FundingContributor.where(
            funding_value: fv,
            name: previous_name
          ).update_all(name: current_name)
        end
      end
    end

    def update(params)
      return false unless at_least_one_name?(params)
      return false unless unique_names?(params)

      PafsCore::FundingContributor.transaction do
        setup_funding_values
        clean_unselected_funding_sources
        funding_values.reject(&:destroyed?).map(&:save!)
        funding_values.reload

        update_changed_contributors(params)
        delete_removed_contributors(params)
        create_new_contributors(params)
      end
    end

    private

    def unique_names?(params)
      return true if step_params(params).pluck(:current).uniq.size == step_params(params).size

      errors.add(:base, "Please add each contributor only once")
      false
    end

    def at_least_one_name?(params)
      return true unless step_params(params).empty?

      errors.add(:base, "Please add at least one contributor")
      false
    end

    def step_params(params)
      @step_params ||= params
                       .permit(name: %i[previous current])
                       .fetch(:name, {}).values
                       .reject { |name| name[:current].strip.blank? }
    end
  end
end
