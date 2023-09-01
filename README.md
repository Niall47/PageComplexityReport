# PageComplexity

W.I.P
A gem to calculate the complexity of a page. The complexity is calculated by counting the number of elements in the page and the number of elements that have a specific class and id. 
A html document is created when you call .generate_report which will show an analysis of each page and an overall summary of the flow

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



## Usages
## Add to navigation method

Useful if you just want to run against a single flow


    @complexity = PageComplexity::Flow.new do |config|
        config.name = "Example flow"
        config.ignore_headers = false
    end

Then, pass the page object by calling .add_page(page) for each page you navigate to.

    @complexity.add_page(page)

When you have finished navigating, call .generate_report to output the results to the console.

    @complexity.generate_report


## Add to rakefile / hooks
This is guesswork!

Useful if you want to run against a whole suite of tests
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





    

    

## Contributing

Bug reports and pull requests are welcome on GitHub at 


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/page_complexity. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/page_complexity/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
