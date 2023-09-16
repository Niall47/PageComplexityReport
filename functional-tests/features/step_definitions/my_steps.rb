Given(/^a user navigates to (.*)$/) do |url|
  visit url
end

Given(/^a user navigates through (.*)$/) do |url|
  visit url
  while page.current_url != url
    # TODO add a loop
    sleep 1
  end
end