require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tweetable
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.generators do |g|
      g.template_engine :erb
      g.stylesheets     false
      g.javascripts     false
      g.test_framework  :rspec, :fixture => true, :views => false
      g.integration_tool :rspec, :fixture => true, :views => true
      g.fixture_replacement :factory_girl, :dir => "spec/support/factories"
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'facebook_config.yml.template')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end
  end
end
