# frozen_string_literal: true

require_relative "page_complexity/version"
require "textstat"
require "erb"
require "ruby-latex"

# TODO spec tests
# TODO update TextStat gem with EN-GB and CY-GB dictionaries
# TODO method comments
# TODO drone setup
# TODO Clean up and colour code the output html, display time to read on the top bar
# TODO do we want to get screenshots? no
# Parse the url to remove the query string when comparing for duplicate pages?
# TODO if the module owned the variable it wont get cleaned up, acts as singleton
module PageComplexity
  class Error < StandardError; end

  def self.flow
    @flow
  end

  def self.flow=(flow)
    @flow = flow
  end

  def configure
    self.config ||= Configuration.new
    yield(config)
  end

  class Flow
    attr_reader :pages, :name

    def initialize(&block)
      @config = Configuration.new
      block.call(@config) if block_given?
      @pages = {}
    end

    class Configuration
      attr_accessor :name, :output_directory, :ignore_headers, :ignore_duplicate_pages, :selector
      #TODO check output directory is respected
      def initialize
        @name = 'Unnamed Flow'
        @output_directory = '/'
        @ignore_headers = false
        @ignore_duplicate_pages = true
        @selector = '#content'
        @filter = "^a-zA-Z0-9_.,!?\"'() \n-"
      end
    end

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
      text.delete(@config.filter)
    end

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

  def self.time_to_read(text)
    # TODO extract to contant
    minutes = (TextStat.lexicon_count(text).to_f / 200)
    LOG.info "Time to read is #{minutes.round(0)} minutes"
    minutes.round(0).to_s
  end

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
      analysis[:difficult_words] = TextStat.difficult_words(text)
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
end
