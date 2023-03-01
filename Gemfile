# frozen_string_literal: true

source "https://rubygems.org"

# Declare your gem's dependencies in pafs_core.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem "govuk_design_system_formbuilder"

gem "dibble", "~> 0.1",
    git: "https://github.com/tonyheadford/dibble",
    branch: "develop"
gem "sprockets", "< 4"
gem "sprockets-rails"

gem "rubyzip"

group :development, :test do
  gem "byebug"
  gem "capybara"
  gem "climate_control"
  gem "defra_ruby_style"
  gem "dotenv"
  gem "factory_bot_rails"
  gem "github_changelog_generator"
  gem "json_schemer"
  gem "pg"
  gem "pry"
  gem "pry-rails"
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "rubocop"
  gem "rubocop-rails"
  gem "rubocop-rspec"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "vcr"
  gem "webmock"
end

group :test do
  gem "database_cleaner"
  gem "faker"
  gem "memory_profiler"
end
