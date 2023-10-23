# frozen_string_literal: true

require_relative "lib/tainted/version"

Gem::Specification.new do |spec|
  spec.name = "tainted"
  spec.version = Tainted::VERSION
  spec.authors = ["Syed Faraaz Ahmad"]
  spec.email = ["faraaz98@live.com"]

  spec.summary = "Gem to perform taint checking on your Ruby code"
  spec.homepage = "https://github.com/faraazahmad/tainted"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/faraazahmad/tainted"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
