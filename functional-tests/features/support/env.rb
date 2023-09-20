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
# Set the Logger Level to output in terminal
LOG.level = Logger.const_get(Settings.test.log_level)

supported_executions = %i[local drone docker]
execution = symbolize(Settings.browser_config.execution)
browser = symbolize(Settings.browser_config.browser)

raise "Unsupported execution: '#{execution}'" unless supported_executions.include?(execution)

require 'webdrivers' if execution.eql?(:local)

if Settings.browser_config.headless || %i[drone docker].include?(execution)
  case browser
  when :edge
    DVLA::Browser::Drivers.headless_edge
  when :firefox
    DVLA::Browser::Drivers.headless_firefox
  else
    DVLA::Browser::Drivers.headless_chrome
  end
else
  DVLA::Browser::Drivers.chrome
end

Capybara.app_host = Settings.browser_config.app_host


LOG.info("App Host: '#{Capybara.app_host}' | Driver: '#{Capybara.default_driver}'")
LOG.debug("Current capabilities: #{Capybara.current_session.driver.browser.capabilities.as_json}")
