# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

task :build do
  sh "gem build page_complexity.gemspec"
  sh "gem install page_complexity-0.1.0.gem"
end

task :run do
  require "capybara/dsl"
  require "page_complexity"
  require "pry"
  include Capybara::DSL
  Capybara.default_driver = :selenium # or your preferred driver
  Capybara.app_host = "https://gov.uk" # set your desired base URL
  visit("/")

  complexity = PageComplexity::Flow.new do |config|
    config.name = "test"
    config.ignore_headers = false
  end
  complexity.add_page(page)
  binding.pry
  complexity.generate_report

end
