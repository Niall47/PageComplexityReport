# PageComplexity

W.I.P

A gem to calculate the complexity of a page. The complexity is calculated by counting the number of elements in the page and the number of elements that have a specific class and id. 
A html document is created when you call .generate_report which will show an analysis of each page and an overall summary of the flow

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

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG



# Usage:
## Add to navigation method

If you just want to run against a single flow:

Create the flow object and pass a configuration block to it

    @complexity = PageComplexity::Flow.new do |config|
        config.ignore_duplicate_pages = true
        config.ignore_headers = false
        config.name = "Example flow"
        config.output_directory = "reports"
        config.selector = '#content'
    end

Then, pass the page object by calling .add_page(page) for each page you navigate to.

    @complexity.add_page(page)

When you have finished navigating, call .generate_report to output the results to the console.

    @complexity.generate_report!


## Add to rakefile / hooks.rb
### WIP - not working
If you want to run against a whole suite of tests
### Rakefile    

    @complexity = PageComplexity::Flow.new do |config|
        config.name = "Example flow"
        config.ignore_headers = false
    end
    bundle exec cucumber

### hooks.rb
    After do |scenario|
        if page?
            @complexity.add_page(page)
        end
    end
