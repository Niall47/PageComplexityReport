Given(/^a user navigates to (.*)$/) do |url|
  visit url
end

Given(/^a user navigates through (.*)$/) do |url|

  # SETUP COMPLEXITY REPORT
  @complexity = PageComplexity::Flow.new do |config|
    config.ignore_duplicate_pages = true
    config.ignore_headers = false
    config.name = "Example flow"
    config.output_directory = "reports"
    config.selector = '#content'
  end


  visit 'http://www.gov.uk'
  while page.current_url != url
    # ADD PAGE TO COMPLEXITY REPORT
    LOG.info "Adding page #{page.current_url} to complexity report"
    @complexity.add_page(page)
    current_url = URI.parse(page.current_url).host
    case current_url
    when 'www.gov.uk'
      visit 'https://www.google.com'
    when 'www.google.com'
      visit 'https://www.bing.com'
    when 'www.bing.com'
      visit 'https://www.yahoo.com'
    when 'consent.yahoo.com'
      visit 'https://duckduckgo.com'
    when 'duckduckgo.com'
      visit 'https://www.wolframalpha.com'
    when 'www.wolframalpha.com'
      visit 'https://www.wikipedia.org'
    else
      fail "Unknown search engine #{current_url}"
    end
    # GENERATE PAGE COMPLEXITY REPORT
    @complexity.generate_report
  end
end