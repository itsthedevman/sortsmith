# frozen_string_literal: true

require_relative "lib/sortsmith/version"

Gem::Specification.new do |spec|
  spec.name = "sortsmith"
  spec.version = Sortsmith::VERSION
  spec.authors = ["Bryan"]
  spec.email = ["bryan@itsthedevman.com"]

  spec.summary = "A flexible Ruby sorting library with a chainable API for transforming and filtering collections. Supports sorting by keys, methods, case sensitivity, and custom transformations."
  spec.homepage = "https://github.com/itsthedevman/sortsmith"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/itsthedevman/sortsmith"
  spec.metadata["changelog_uri"] = "https://github.com/itsthedevman/sortsmith/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github .direnv appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
