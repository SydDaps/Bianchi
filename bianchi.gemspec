# frozen_string_literal: true

require_relative "lib/bianchi/version"

Gem::Specification.new do |spec|
  spec.name          = "bianchi"
  spec.version       = Bianchi::VERSION
  spec.authors       = ["Dapilah Sydney"]
  spec.email         = ["dapilah.sydney@gmail.com"]

  spec.summary       = <<~MSG
    A DSL (Domain-Specific Language) and a minimalist framework in Ruby, tailored for USSD development.
  MSG

  spec.homepage      = "https://github.com/SydDaps/Bianchi"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.metadata["homepage_uri"] = "https://github.com/SydDaps/Bianchi"
  spec.metadata["source_code_uri"] = "https://github.com/SydDaps/Bianchi"
  spec.metadata["changelog_uri"] = "https://rubygems.org/"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activesupport"
  spec.add_dependency "json"
  spec.add_dependency "redis"
  spec.add_dependency "thor"
  spec.metadata["rubygems_mfa_required"] = "true"
end
