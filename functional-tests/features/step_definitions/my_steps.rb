Given(/^a user navigates to (.*)$/) do |url|
  visit url
end

Given(/^a user navigates through (.*)$/) do |url|

  # SETUP COMPLEXITY REPORT
  new_flow = PageComplexity::Flow.new do |config|
    config.ignore_duplicate_pages = true
    config.ignore_headers = false
    config.name = "Step_walker_demo"
    config.output_directory = "reports"
    config.selector = "#content"
  end
  PageComplexity.flow = new_flow

  visit 'http://www.gov.uk'
  while page.current_url != url
    # ADD PAGE TO COMPLEXITY REPORT
    PageComplexity.flow.add_page(page)
    current_url = URI.parse(page.current_url).host
    case current_url
    when 'www.gov.uk'
      visit 'https://www.google.com'
    when 'www.google.com'
      visit 'https://www.yahoo.com'
    when 'consent.yahoo.com'
      visit 'https://duckduckgo.com'
    when 'duckduckgo.com'
      visit 'https://en.wikipedia.org/wiki/English_language'
    when 'en.wikipedia.org'
      visit 'https://simple.wikipedia.org/wiki/String_theory'
    when 'simple.wikipedia.org'
      visit 'https://en.wikipedia.org/wiki/String_theory'
    else
      fail "Unknown search engine #{current_url}"
    end
  end
  # GENERATE PAGE COMPLEXITY REPORT
  PageComplexity.flow.add_page(page)
  PageComplexity.flow.generate_report!
end
