# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in sortsmith.gemspec
gemspec

gem "rake", "~> 13.0"

group :development do
  gem "benchmark-ips"
end

group :development, :lint do
  gem "standard", "~> 1.52"
  gem "pry", "~> 0.15.2"
end

group :development, :documentation do
  gem "yard"
  gem "kramdown"
end

group :test do
  gem "minitest", "~> 5.16"
end
