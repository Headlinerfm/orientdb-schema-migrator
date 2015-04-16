# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orientdb_schema_migrator/version'
require 'rake'

Gem::Specification.new do |spec|
  spec.name          = "orientdb_schema_migrator"
  spec.version       = OrientdbSchemaMigrator::VERSION
  spec.authors       = ["CoPromote"]
  spec.email         = ["info@copromote.com"]
  spec.summary       = %q{Migrate OrientDB schema}
  spec.description   = %q{Migrate OrientDB schema}
  spec.homepage      = "https://copromote.com"
  spec.license       = "MIT"

  spec.files         = FileList['lib/**/*.rb', '[A-Z]*'].exclude('Gemfile*')
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "orientdb4r"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "climate_control", ">= 0.0.3"
end
