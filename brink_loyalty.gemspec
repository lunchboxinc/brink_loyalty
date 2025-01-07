# frozen_string_literal: true

require_relative "lib/brink_loyalty/version"

Gem::Specification.new do |spec|
  spec.name          = "brink_loyalty"
  spec.version       = BrinkLoyalty::VERSION
  spec.authors       = ["Zach Colon, Nikhil Gupta"]
  spec.email         = ["engineering@lunchbox.io"]
  spec.summary       = %q{Ruby gem for integrating with the Brink Generic Loyalty API}
  spec.description   = %q{A Ruby gem that provides a simple SDK for interacting with the Brink Generic Loyalty endpoints.}
  spec.homepage      = "https://github.com/yourorg/brink_loyalty"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb", "README.md"]
  spec.required_ruby_version = ">= 2.6"

  spec.add_dependency "rails", ">= 5.2"

  spec.metadata = {
    "source_code_uri" => "https://github.com/lunchboxinc/brink_loyalty"
  }

  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_dependency "pry"
  spec.add_development_dependency "webmock"
end
