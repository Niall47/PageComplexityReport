# frozen_string_literal: true

require_relative "page_complexity/version"
require "textstat"
require "erb"

# TODO spec tests
# TODO update TextStat gem with EN-GB and CY-GB dictionaries
# TODO method comments
# TODO drone setup
# TODO Clean up and colour code the output html, display time to read on the top bar
# TODO do we want to get screenshots? no
# Parse the url to remove the query string when comparing for duplicate pages?
# TODO if the module owned the variable it wont get cleaned up, acts as singleton
module PageComplexity
  AVERAGE_WORDS_PER_MINUTE = 200
  DEFAULT_SELECTOR = '#content'
  REGEX_FILTER = "^a-zA-Z0-9_.,!?\"'() \n-"

  # Custom error class for PageComplexity module
  class Error < StandardError; end

  # Yields the configuration for PageComplexity
  #
  # @yieldparam config [Configuration] the configuration object
  def configure
    self.config ||= Configuration.new
    yield(config)
  end

  # @return [Flow] the flow instance
  def self.flow
    @flow
  end

  # @param flow [Flow] the flow instance to set
  def self.flow=(flow)
    @flow = flow
  end

  # Calculates time to read based on average words per minute
  #
  # @param text [String] the input text
  # @return [String] the formatted time to read
  def self.time_to_read(text)
    words = TextStat.lexicon_count(text)
    minutes = (words.to_f / AVERAGE_WORDS_PER_MINUTE)
    total_seconds = minutes * 60
    minutes_part = total_seconds.to_i / 60
    seconds_part = total_seconds.to_i % 60
    time_string = "#{minutes_part} minutes and #{seconds_part} seconds"
    LOG.info "Time to read is #{time_string}"
    time_string
  end


  # Analyzes text for various readability metrics using TextStat gem
  #
  # @param text [String] the input text
  # @return [Hash] the analysis results
  def self.analyze(text:)
    analysis = {}
    if text.empty?
      analysis[:error] = 'No text found'
    else
      # TODO do we care about many of these?
      analysis[:time_to_read] = time_to_read(text)
      analysis[:char_count] = TextStat.char_count(text)
      analysis[:lexicon_count] = TextStat.lexicon_count(text)
      analysis[:syllable_count] = TextStat.syllable_count(text)
      analysis[:sentence_count] = TextStat.sentence_count(text)
      analysis[:avg_sentence_length] = TextStat.avg_sentence_length(text)
      analysis[:avg_syllables_per_word] = TextStat.avg_syllables_per_word(text)
      analysis[:avg_letter_per_word] = TextStat.avg_letter_per_word(text)
      analysis[:avg_sentence_per_word] = TextStat.avg_sentence_per_word(text)
      analysis[:difficult_words] = TextStat.difficult_words(text).join(' ')
      analysis[:flesch_reading_ease] = TextStat.flesch_reading_ease(text)
      analysis[:flesch_kincaid_grade] = TextStat.flesch_kincaid_grade(text)
      analysis[:gunning_fog] = TextStat.gunning_fog(text)
      analysis[:smog_index] = TextStat.smog_index(text)
      analysis[:automated_readability_index] = TextStat.automated_readability_index(text)
      analysis[:coleman_liau_index] = TextStat.coleman_liau_index(text)
      analysis[:linsear_write_formula] = TextStat.linsear_write_formula(text)
      analysis[:dale_chall_readability_score] = TextStat.dale_chall_readability_score(text)
      analysis[:lix] = TextStat.lix(text)
      analysis[:forcast] = TextStat.forcast(text)
      analysis[:powers_sumner_kearl] = TextStat.powers_sumner_kearl(text)
      analysis[:spache] = TextStat.spache(text)
    end
    analysis
  end

  # Manages multiple pages for analysis
  class Flow
    # @return [Hash] the pages and their information
    attr_reader :pages

    # Initializes the Flow with optional configuration block
    #
    # @yieldparam config [Configuration] the configuration object
    def initialize(&block)
      @config = Configuration.new
      block.call(@config) if block_given?
      @pages = {}
    end

    # Configuration settings for Flow
    class Configuration
      # @return [String] the name of the configuration
      attr_accessor :name

      # @return [String] the output directory path
      attr_accessor :output_directory

      # @return [Boolean] whether to ignore headers during text extraction
      attr_accessor :ignore_headers

      # @return [Boolean] whether to ignore duplicate pages
      attr_accessor :ignore_duplicate_pages

      # @return [String] the CSS selector for content
      attr_accessor :selector

      # @return [String] the regex filter for text
      attr_accessor :filter

      # @return [Integer] the average words per minute for time-to-read calculation
      attr_accessor :words_per_minute

      # TODO: Check if the output directory is respected
      def initialize
        @filter = REGEX_FILTER
        @ignore_duplicate_pages = true
        @ignore_headers = false
        @name = 'Unnamed Flow'
        @output_directory = '/'
        @selector = DEFAULT_SELECTOR
        @words_per_minute = AVERAGE_WORDS_PER_MINUTE
      end
    end

    # Retrieves text from a page based on configuration
    #
    # @param page [Capybara::Session] the Capybara page
    # @return [String] the extracted text
    def page_text(page)
      text = if @config.ignore_headers
               find_all(@config.selector).map(&:text).join(' ')
             else
               page.text
             end
      if text.empty?
        LOG.warn "Found no text on #{page.current_url}"
        LOG.debug "Config: #{@config.inspect}"
      end
      text.delete(@config.filter).gsub("\n", ' ')
    end

    # Adds a page to the flow
    #
    # @param page [Capybara::Session] the Capybara page to add
    def add_page(page)
      raise "Page must be a capybara page not a #{page.class}" unless page.is_a?(Capybara::Session)

      if pages.keys.include?(page.current_url) && @config.ignore_duplicate_pages
        LOG.info "Ignoring duplicate page #{page.current_url}"
      else
        LOG.info "Adding page #{page.current_url}"
        text = page_text(page)
        analysis = text.empty? ? { error: 'No text found' } : PageComplexity.analyze(text: text)
        new_page = Page.new(analysis: analysis, text: text, url: page.current_url)
        @pages[page.current_url] = new_page
      end
    end

    # Adds an array of pages to the flow
    #
    # @param pages [Array<Capybara::Session>] the array of Capybara pages to add
    def add_pages(pages)
      raise "Expected an array of pages" unless (pages.is_a? Array) && (pages.all? { |page| page.is_a?(Capybara::Session) })

      # TODO do we need to dup or freeze them first?

      pages.each { |page| add_page(page) }
    end


    def generate_report!
      _analysis_metrics = @pages.first.last.analysis.keys
      template_path = File.join(File.dirname(__FILE__), 'page_complexity/template.html.erb')
      template = ERB.new(File.read(template_path))
      report_content = template.result(binding)

      # @output_directory
      # Assuming you want to save the report to a file
      report_file_path = "#{@config.name}_readability_report_#{DateTime.now.strftime('%d-%m-%Y_%H-%M-%S')}.html"
      File.open(report_file_path, 'w') do |file|
        file.puts report_content
      end
    end
  end

  class Page
    attr_reader :analysis, :text, :url

    def initialize(analysis: {}, text: nil, url: nil)
      @analysis = analysis
      @text = text
      @url = url
    end
  end

end
