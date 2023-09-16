Before('@wip or @manual') do |_scenario|
  skip_this_scenario
end

AfterStep('@after-step-demo') do |_result, step|
  LOG.info("Step: #{step}")
  LOG.info("Current URL: #{current_url}")
  LOG.info("Current Title: #{page.title}")
end

Before do |scenario|
  LOG.new_scenario(scenario.id)
  LOG.info("Running Scenario: #{scenario.name}")
end

After do |scenario|
  if scenario.failed?
    LOG.info('Scenario Failed - Taking screenshot & attaching test_data')
    LOG.info("Current URL: #{current_url}")

    add_attachments(scenario_name: scenario.name.slice(0..23))
  end
end

After do |scenario|
  LOG.info("Finished running: '#{scenario.name}' from '#{scenario.location.file}'")
end

After do |_scenario|
  if Settings.test.accessibility
    LOG.info("Checking accessibility on: '#{page.current_url}'")

    step('the page should be axe clean')
  end
end
