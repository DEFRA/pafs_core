# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "pafs_core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pafs_core"
  s.version     = PafsCore::VERSION
  s.authors     = ["CIS Solutions Delivery, Environment Agency"]
  s.email       = ["tony.headford@environment-agency.gov.uk"]
  s.homepage    = "https://github.com/DEFRA"
  s.summary     = "Project Application and Funding Service core shared functionality"
  s.description = "Project Application and Funding Service core shared functionality"
  s.license     = "The Open Government Licence (OGL) Version 3"
  s.required_ruby_version = ">= 3.1"

  s.files = Dir[
    "{app,config,db,lib}/**/*",
    "spec/factories/**/*",
    "spec/support/**/*",
    "LICENSE",
    "Rakefile",
    "README.md"]
  s.metadata["rubygems_mfa_required"] = "true"

  s.add_dependency "aws-sdk-s3", "~> 1.67"
  s.add_dependency "bstard"
  s.add_dependency "clamav-client"
  s.add_dependency "faraday"
  s.add_dependency "kaminari"
  s.add_dependency "net-smtp"
  s.add_dependency "nokogiri"
  s.add_dependency "rack-cors"
  s.add_dependency "rails", "~> 6.1"
  s.add_dependency "roo"
  s.add_dependency "rubyXL"
  s.add_dependency "secure_headers"

  # defra_ruby_alert is a gem we created to manage airbrake across projects
  s.add_dependency "defra_ruby_alert", "~> 2.1"

  # GOV.UK styling
  s.add_dependency "defra_ruby_template", "~> 3"
  s.add_dependency "govuk_design_system_formbuilder", "~> 3"
end
