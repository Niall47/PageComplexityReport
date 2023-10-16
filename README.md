# PageComplexity

W.I.P

A gem to calculate the complexity of a page. The complexity is calculated by counting the number of elements in the page and the number of elements that have a specific class and id. 
A html document is created when you call .generate_report! which will show an analysis of each page and an overall summary of the flow

This relies heavily on Capybara to parse the page for text and the TextStat gem for providing the readability scores.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'page_complexity'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install page_complexity



# Usage:
## Capturing a single navigation flow

If you just want to run against a single flow you can wrap your existing navigation method:

### your_navigation_steps.rb

    new_flow = PageComplexity::Flow.new do |config|
        config.ignore_duplicate_pages = true
        config.ignore_headers = false
        config.name = "Step_walker_demo"
        config.output_directory = "reports"
        config.selector = "#content"
    end
    PageComplexity.flow = new_flow

    while page != desired_page
        walk_to_page
        PageComplexity.flow.add_page(page)
    end

    PageComplexity.flow.generate_report!



## Capturing all pages test pack

If you want to run against a whole suite of tests

### env.rb

    new_flow = PageComplexity::Flow.new do |config|
        config.ignore_duplicate_pages = true
        config.ignore_headers = false
        config.name = "Step_walker_demo"
        config.output_directory = "reports"
        config.selector = "#content"
    end
    PageComplexity.flow = new_flow

### hooks.rb

    After do
        PageComplexity.flow.add_page(page)
    end

    at_exit do
        PageComplexity.flow.generate_report!
    end
