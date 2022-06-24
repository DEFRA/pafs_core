# frozen_string_literal: true

module PafsCore
  module EnvironmentalOutcomes
    OM4_ATTRIBUTES = %i[
      intertidal_habitat
      hectares_of_intertidal_habitat_created_or_enhanced
      woodland
      hectares_of_woodland_habitat_created_or_enhanced
      wet_woodland
      hectares_of_wet_woodland_habitat_created_or_enhanced
      wetland_or_wet_grassland
      hectares_of_wetland_or_wet_grassland_created_or_enhanced
      grassland
      hectares_of_grassland_habitat_created_or_enhanced
      heathland
      hectares_of_heathland_created_or_enhanced
      ponds_lakes
      hectares_of_pond_or_lake_habitat_created_or_enhanced
      arable_land
      hectares_of_arable_land_lake_habitat_created_or_enhanced
      comprehensive_restoration
      kilometres_of_watercourse_enhanced_or_created_comprehensive
      partial_restoration
      kilometres_of_watercourse_enhanced_or_created_partial
      create_habitat_watercourse
      kilometres_of_watercourse_enhanced_or_created_single
    ].freeze

    OM4_ATTRIBUTES.each do |r|
      delegate r, "#{r}=", "#{r}?", to: :project
    end

    delegate  :environmental_benefits,
              :environmental_benefits=,
              :environmental_benefits?,
              to: :project

    def selected_om4_attributes
      OM4_ATTRIBUTES.select { |r| send("#{r}?") }
    end

    def environmental_outcomes_started?
      !environmental_benefits.nil?
    end
  end
end
