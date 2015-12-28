$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "support/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "support"
  s.version     = Support::VERSION
  s.authors     = ["Dmitry Koprov"]
  s.email       = ["dmitry.koprov@gmail.com"]
  s.homepage    = "https://github.com/octoshell/octoshell-v2"
  s.summary     = "An for users support in octoshell"
  s.description = "Provides fuctionality of the helpdesk for octoshell users"
  s.license     = "MIT"
  s.platform    = "java"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2"

  s.add_dependency "activerecord-jdbcpostgresql-adapter"
  s.add_dependency "decorators", "~> 1.0.2"
  s.add_dependency "state_machines-activerecord"
  s.add_dependency "slim"
  s.add_dependency "sidekiq"
  s.add_dependency "maymay"
  s.add_dependency "ransack"
  s.add_dependency "kaminari"
  s.add_dependency "mini_magick"
  s.add_dependency "carrierwave"

  s.add_development_dependency "rspec-rails"
end
