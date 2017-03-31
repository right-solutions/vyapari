module Vyapari
  class Engine < ::Rails::Engine
  	require 'kaminari'
  	require 'kuppayam'
  	require 'usman'
    
    isolate_namespace Vyapari

    config.before_initialize do                                                      
      config.i18n.load_path += Dir["#{config.root}/config/locales/**/*.yml"]
    end

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/dummy/spec/factories'
      g.assets false
      g.helper false
    end
  end
end
