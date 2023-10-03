AfterStep('@after-step-demo') do |_result, step|
  LOG.info("Step: #{step}")
  LOG.info("Current URL: #{current_url}")
  LOG.info("Current Title: #{page.title}")
end
