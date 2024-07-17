# frozen_string_literal: true

module PafsCore
  class FundingValue < ApplicationRecord
    belongs_to :project

    contributor_class_name = "PafsCore::FundingContributor"

    has_many :funding_contributors, dependent: :destroy
    has_many :public_contributions, -> { where(contributor_type: FundingSources::PUBLIC_CONTRIBUTIONS) },
             class_name: contributor_class_name
    has_many :private_contributions, -> { where(contributor_type: FundingSources::PRIVATE_CONTRIBUTIONS) },
             class_name: contributor_class_name
    has_many :other_ea_contributions, -> { where(contributor_type: FundingSources::EA_CONTRIBUTIONS) },
             class_name: contributor_class_name

    validates :fcerm_gia,
              :local_levy,
              :internal_drainage_boards,
              :not_yet_identified,
              numericality: true, allow_blank: true

    before_save :update_total

    def self.previous_years
      where(financial_year: -1)
    end

    def self.to_financial_year(year)
      where(arel_table[:financial_year].lteq(year.to_i)).order(:financial_year)
    end

    FundingSources::ALL_FUNDING_SOURCES.each do |source|
      next if FundingSources::REMOVED_FROM_FUNDING_VALUES.include?(source)

      define_method("#{source}_total") do
        return public_send(source).to_i unless FundingSources::AGGREGATE_SOURCES.include?(source)

        (public_send(source) || []).map(&:amount).compact.sum.to_i
      end
    end

    def any_positive_values?
      all_non_aggr_non_removed_funding_sources = PafsCore::FundingSources::ALL_FUNDING_SOURCES -
                                                 PafsCore::FundingSources::REMOVED_FROM_FUNDING_VALUES -
                                                 PafsCore::FundingSources::AGGREGATE_SOURCES

      return false if all_non_aggr_non_removed_funding_sources.reduce(0) { |sum, fs| sum + send(fs).to_i }.zero? &&
                      public_contributions.reduce(0) { |sum, pc| sum + pc.amount.to_i }.zero? &&
                      private_contributions.reduce(0) { |sum, pc| sum + pc.amount.to_i }.zero? &&
                      other_ea_contributions.reduce(0) { |sum, pc| sum + pc.amount.to_i }.zero?

      true
    end

    def financial_year_in_range?(year_from, year_to)
      return false if financial_year.nil?

      financial_year >= year_from && financial_year <= year_to
    end

    private

    def selected_funding_sources
      (
        FundingSources::ALL_FUNDING_SOURCES - FundingSources::REMOVED_FROM_FUNDING_VALUES
      ).select do |s|
        project.public_send "#{s}?"
      end
    end

    def update_total
      return if destroyed?

      self.total = selected_funding_sources.map { |f| public_send("#{f}_total") }.reduce(:+) || 0
    end
  end
end
