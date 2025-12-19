# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in sortsmith.gemspec
gemspec

gem "rake"

group :development do
  gem "benchmark-ips"
end

group :development, :lint do
  gem "standard"
  gem "pry"
end

group :development, :documentation do
  gem "yard"
  gem "kramdown"
end

group :test do
  gem "minitest", "~> 5"
end
