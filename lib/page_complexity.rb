# frozen_string_literal: true

require_relative "page_complexity/version"
require "textstat"
require "erb"
require "ruby-latex"

module PageComplexity
  class Error < StandardError; end

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
      attr_accessor :name, :output_directory, :ignore_headers

      def initialize
        @name = 'Unnamed Flow'
        @output_directory = '/'
        @ignore_headers = false
      end
    end

    def get_text(page)
      text = if @config.ignore_headers
               # TODO should we be hardcoding the selector here?
               find_all('#content').map(&:text).join(' ')
            else
              page.text
             end
      raise "Text is empty" if text.empty?

      text
    end

    def add_page(page)
      raise "Page must be a capybara page" unless page.is_a?(Capybara::Session)

      if pages.keys.include?(page.current_url)
        puts "We have a duplicate page"
      else
        text = get_text(page)
        analysis = PageComplexity.analyze(text: text)
        new_page = Page.new(analysis: analysis, text: text, url: page.current_url)
        @pages[page.current_url] = new_page
      end
    end

    def generate_report
      generate_total_read_time
      _analysis_metrics = @pages.first.last.analysis.keys
      template_path = File.join(File.dirname(__FILE__), 'page_complexity/template.html.erb')
      template = ERB.new(File.read(template_path))
      report_content = template.result(binding)

      # @output_directory
      # Assuming you want to save the report to a file
      report_file_path = "#{@flow}_readability_report_#{DateTime.now.strftime('%d-%m-%Y_%H-%M-%S')}.html"
      File.open(report_file_path, 'w') do |file|
        file.puts report_content
      end
    end

    def generate_total_read_time
      @pages.each_pair do |key, value|
        value.analysis[:page_read_time] = (value.analysis[:lexicon_count] / 200).round(2)
        puts "Approximate read time for #{key} is #{value.analysis[:page_read_time]} minutes"
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

  def self.analyze(text:)
    analysis = {}

    analysis[:char_count] = TextStat.char_count(text)
    analysis[:lexicon_count] = TextStat.lexicon_count(text)
    analysis[:syllable_count] = TextStat.syllable_count(text, language = 'en_uk')
    analysis[:sentence_count] = TextStat.sentence_count(text)
    analysis[:avg_sentence_length] = TextStat.avg_sentence_length(text)
    analysis[:avg_syllables_per_word] = TextStat.avg_syllables_per_word(text, language = 'en_uk')
    analysis[:avg_letter_per_word] = TextStat.avg_letter_per_word(text)
    analysis[:avg_sentence_per_word] = TextStat.avg_sentence_per_word(text)
    analysis[:difficult_words] = TextStat.difficult_words(text, language = 'en_uk', return_words: true)

    analysis[:flesch_reading_ease] = TextStat.flesch_reading_ease(text, language = 'en_uk')
    analysis[:flesch_kincaid_grade] = TextStat.flesch_kincaid_grade(text, language = 'en_uk')
    # analysis[:gunning_fog] = TextStat.gunning_fog(text, language = 'en_uk')
    analysis[:smog_index] = TextStat.smog_index(text, language = 'en_uk')
    analysis[:automated_readability_index] = TextStat.automated_readability_index(text)
    analysis[:coleman_liau_index] = TextStat.coleman_liau_index(text)
    analysis[:linsear_write_formula] = TextStat.linsear_write_formula(text, language = 'en_uk')
    # analysis[:dale_chall_readability_score] = TextStat.dale_chall_readability_score(text, language = 'en_uk')
    analysis[:lix] = TextStat.lix(text)
    analysis[:forcast] = TextStat.forcast(text, language = 'en_uk')
    analysis[:powers_sumner_kearl] = TextStat.powers_sumner_kearl(text, language = 'en_uk')
    analysis[:spache] = TextStat.spache(text, language = 'en_uk')
    analysis
  end
end


# TODO
# Think of a cool name for the gem - FlowVisor FlowAnalytics
# Make sure the number output are correct and not being skewed by the html
# Spec tests
# EN & CY support
# optionally strip the header and footer out of the page - Done
# remove any wierd characters that are messing up the result
# take an arg for the output file location - Done
# update the template to colour code good and bad results
# Add an estimated journey time - In progress


# Mentortainment
# Or just an after hook
# PageComplexity::Flow.new(name: 'Identity-UI') in the env.rb
# store as a hash so we can overwrite repeating pages
# at_exit do generate report
#TODO I don't think this will work, won't the instance be overwritten each scenario?

# convert scores into meaningful stats
# Latex, research me
# Mixin to add to some of the silly methods