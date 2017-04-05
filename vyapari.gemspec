$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "vyapari/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "vyapari"
  s.version     = Vyapari::VERSION
  s.authors     = ["kpvarma"]
  s.email       = ["krshnaprsad@gmail.com"]
  s.homepage    = "https://github.com/right-solutions/vyapari"
  s.summary     = "An online product catelog for general traders"
  s.description = "Comes with an admin interface to configure brands, multilevel categories & products"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'rails', '~> 5.0', '>= 5.0.2'
  s.add_dependency 'jquery-rails', '~> 4.2', '>= 4.2.2'
  s.add_dependency 'kaminari', '~> 1.0', '>= 1.0.1'
  s.add_dependency 'bootstrap-kaminari-views', "~> 0.0.5"
  s.add_dependency 'axlsx', '~> 2.0.1'

  s.add_dependency 'kuppayam', "~> 0.1.5dev"
  s.add_dependency 'usman', "~> 0.1.5dev1"
  s.add_dependency "bcrypt"

  s.add_development_dependency 'pry', "~> 0.10.1", ">= 0.10.0"
  s.add_development_dependency 'mysql2', "~> 0.4.4"
  s.add_development_dependency 'sqlite3', "~> 1.3.10", ">= 1.3.9"
  s.add_development_dependency 'carrierwave', "~> 0.10.0", ">= 0.9.0"
  s.add_development_dependency 'rmagick', "~> 2.13.3", ">= 2.13.2"
  s.add_development_dependency 'rspec-rails', "~> 3.5"
  s.add_development_dependency 'capybara', "~> 2.4.4", ">= 2.4.3"
  s.add_development_dependency 'factory_girl_rails', "~> 4.8.0", ">= 4.4.0"
  s.add_development_dependency 'database_cleaner', "~> 1.4.0", ">= 1.3.0"
  s.add_development_dependency 'shoulda-matchers', "~> 3.1"
end
