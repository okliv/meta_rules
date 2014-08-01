$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require 'meta_rules/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'meta_rules'
  s.version     = MetaRules::VERSION
  s.authors     = ["okliv"]
  s.email       = ["@"]
  s.homepage    = "http://google.com"
  s.summary     = "MetaRules - dynamic patterns for SEO meta tags"
  s.description = "Define with ease dynamic rules to compose SEO meta tags (title, description, keywords, h1) and alt-n-title for images using simple YML syntax"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", ">= 3.1"
  #
  # s.add_development_dependency "sqlite3"
end
