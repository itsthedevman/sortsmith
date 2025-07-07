# frozen_string_literal: true

require_relative "lib/sortsmith/version"

Gem::Specification.new do |spec|
  spec.name = "sortsmith"
  spec.version = Sortsmith::VERSION
  spec.authors = ["Bryan"]
  spec.email = ["bryan@itsthedevman.com"]

  spec.summary = "A flexible Ruby sorting library with a chainable API for transforming and filtering collections. Supports sorting by keys, methods, case sensitivity, and custom transformations."
  spec.description = "Sortsmith provides a flexible, chainable API for sorting Ruby collections. It supports sorting by object keys, methods, case sensitivity, and custom transformations."
  spec.homepage = "https://github.com/itsthedevman/sortsmith"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata = {
    "source_code_uri" => "https://github.com/itsthedevman/sortsmith",
    "changelog_uri" => "https://github.com/itsthedevman/sortsmith/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/itsthedevman/sortsmith/issues",
    "documentation_uri" => "https://github.com/itsthedevman/sortsmith#readme",
    "rubygems_mfa_required" => "true"
  }

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github .direnv appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]
end
