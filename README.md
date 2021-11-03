# Project Application and Funding Service (PAFS) Core Shared

[![CI](https://github.com/DEFRA/pafs_core/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/DEFRA/pafs_core/actions/workflows/ci.yml)
[![Code Climate](https://codeclimate.com/github/DEFRA/pafs_core/badges/gpa.svg)](https://codeclimate.com/github/DEFRA/pafs_core)
[![Test Coverage](https://codeclimate.com/github/DEFRA/pafs_core/badges/coverage.svg)](https://codeclimate.com/github/DEFRA/pafs_core/coverage)
[![security](https://hakiri.io/github/DEFRA/pafs_core/develop.svg)](https://hakiri.io/github/DEFRA/pafs_core/develop)

A Rails Engine for [Project Application and Funding Service](https://github.com/DEFRA/pafs-user)

## PAFS Documentation
For a full breakdown of the PAFS documentation, technical and non technical please click the [link](https://aimspd.sharepoint.com/sites/pwa_dev/AIMS%20Project%20Delivery%20Collaboration/_layouts/15/guestaccess.aspx?docid=08fcc88cb3f7c45b48a274bf0ea4132f5&authkey=AWuSgciHOQlICM9DP0JtdRA)

## Versions

The project is currently using Ruby version 2.3.0 and Rails 4.2.7.1.

## Installation

Add the gem to your Gemfile

```ruby
gem 'pafs_core',
  git: 'https://github.com/EnvironmentAgency/pafs_core', branch: 'develop'
```

Then run:

```bash
bundle install
```

## Tests

We use [RSpec](http://rspec.info/) for unit testing, and intend to use [Cucumber](https://github.com/cucumber/cucumber-rails) for our acceptance testing.

To execute the unit tests simply enter;

```bash
bundle exec rspec
```

## Contributing to this project

If you have an idea you'd like to contribute please log an issue.

All contributions should be submitted via a pull request.

## License

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

The following attribution statement MUST be cited in your products and applications when using this information.

> Contains public sector information licensed under the Open Government license v3

### About the license

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable information providers in the public sector to license the use and re-use of their information under a common open licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.
