Given(/^a user navigates to (.*)$/) do |url|
  visit url
end

Given(/^a user navigates through (.*)$/) do |url|
  visit 'http://www.gov.uk'
  while page.current_url != url
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

    # TODO add a loop
    sleep 1
  end
end