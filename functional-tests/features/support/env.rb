Bundler.require
require 'axe-cucumber-steps'
require 'capybara/dsl'
require 'uri'

include RSpec::Matchers

World(Capybara::DSL)

# Load configuration for Config gem
Config.load_and_set_settings(Config.setting_files('./config', ENV.fetch('ENVIRONMENT', 'local')))

# Configure and initialise Logger output
DVLA::Herodotus.configure do |config|
  config.system_name = 'PageComplexityReport-demo'
  config.pid = true
end
LOG = DVLA::Herodotus.logger
LOG.level = Logger.const_get(Settings.test.log_level)

# Setup browser driver
DVLA::Browser::Drivers.firefox
Capybara.app_host = Settings.browser_config.app_host
LOG.info("App Host: '#{Capybara.app_host}' | Driver: '#{Capybara.default_driver}'")
LOG.debug("Current capabilities: #{Capybara.current_session.driver.browser.capabilities.as_json}")

new_flow = PageComplexity::Flow.new do |config|
  config.ignore_duplicate_pages = true
  config.ignore_headers = false
  config.name = "Step_walker_demo"
  config.output_directory = "reports"
  config.selector = "#content"
end
PageComplexity.flow = new_flow
