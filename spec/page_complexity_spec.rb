# frozen_string_literal: true

require_relative "../lib/page_complexity.rb"
require "textstat"
require "capybara"
require "logger"

# Mock Logger for testing purposes
class MockLogger
  def info(_); end

  def warn(_); end

  def debug(_); end
end

RSpec.describe PageComplexity do
  let(:dummy_page) { instance_double(Capybara::Session, text: "Dummy text") }

  before do
    # Replace the original LOG constant with the MockLogger for testing
    stub_const("LOG", MockLogger.new)
  end

  describe ".configure" do
    it "configures the module" do
      # Access the Configuration class directly and set values
      new_flow = PageComplexity::Flow.new do |config|
        config.ignore_duplicate_pages = true
        config.ignore_headers = false
        config.name = "Test Configuration"
        config.output_directory = "reports"
        config.selector = "#content"
      end
      PageComplexity.flow = new_flow

      expect(PageComplexity.flow.config.name).to eq("Test Configuration")
    end
  end

  describe ".flow" do
    it "returns the flow instance" do
      flow_instance = PageComplexity::Flow.new
      PageComplexity.flow = flow_instance

      expect(PageComplexity.flow).to eq(flow_instance)
    end
  end

  describe ".time_to_read" do
    it "calculates time to read" do
      text = "This is a sample text for testing time to read calculation."
      result = PageComplexity.time_to_read(text)

      expect(result).to be_a(String)
    end
  end

  describe ".analyze" do
    it "analyzes text for readability metrics" do
      text = "This is a sample text for readability analysis."
      analysis = PageComplexity.analyze(text: text)

      expect(analysis).to be_a(Hash)
      # Check for the presence of specific keys without caring about specific values
      expect(analysis).to include(
                            :time_to_read,
                            :char_count,
                            :lexicon_count,
                            :syllable_count,
                            :sentence_count,
                            :avg_sentence_length,
                            :avg_syllables_per_word,
                            :avg_letter_per_word,
                            :avg_sentence_per_word,
                            :difficult_words,
                            :flesch_reading_ease,
                            :flesch_kincaid_grade,
                            :gunning_fog,
                            :smog_index,
                            :automated_readability_index,
                            :coleman_liau_index,
                            :linsear_write_formula,
                            :dale_chall_readability_score,
                            :lix,
                            :forcast,
                            :powers_sumner_kearl,
                            :spache
                          )
      expect(analysis[:time_to_read]).to match(/(\d+\s*minutes\s*)?(\d+\s*seconds\s*)?/i)
    end
  end


  describe PageComplexity::Flow do
    let(:flow) { PageComplexity::Flow.new }

    describe "#initialize" do
      it "initializes the Flow instance" do
        expect(flow.pages).to be_a(Hash)
      end
    end

    describe "#page_text" do
      it "retrieves text from a page based on configuration" do
        # Create a dummy Capybara page
        dummy_page = instance_double(Capybara::Session)

        # Configure the Flow with the specified settings
        new_flow = PageComplexity::Flow.new do |config|
          config.ignore_duplicate_pages = true
          config.ignore_headers = false
          config.name = "Step_walker_demo"
          config.output_directory = "reports"
          config.selector = "#content"
        end

        # Stub the find_all method to return an array of elements with dummy text
        allow(dummy_page).to receive(:find_all).with("#content").and_return([double(text: "Dummy text")])

        # Stub the text method to return the concatenated text of the dummy elements
        allow(dummy_page).to receive(:text).and_return("Dummy text")

        PageComplexity.flow = new_flow

        # Depending on your actual implementation, you may need to adjust the expectation
        expect(PageComplexity.flow.page_text(dummy_page)).to eq "Dummy text"
      end
    end

    describe "#add_page" do
      it "adds a page to the flow" do
        page_url = "https://example.com/page1"
        allow(dummy_page).to receive(:current_url).and_return(page_url)

        flow.add_page(dummy_page)

        expect(flow.pages[page_url]).to be_a(PageComplexity::Page)
      end

      it "ignores duplicate pages when configured" do
        page_url = "https://example.com/duplicate"
        allow(dummy_page).to receive(:current_url).and_return(page_url)

        flow.add_page(dummy_page)
        flow.add_page(dummy_page) # Second addition should be ignored

        expect(flow.pages.size).to eq(1)
      end
    end

    describe "#add_pages" do
      it "adds an array of pages to the flow" do
        pages = [dummy_page, dummy_page]

        flow.add_pages(pages)

        # Depending on your actual implementation, you may need to adjust the expectation
        expect(flow.pages.size).to eq(2)
      end
    end

    describe "#generate_report!" do
      it "generates a report based on the analyzed pages" do
        # Depending on your actual implementation, you may need to adjust the expectation
        expect { flow.generate_report! }.not_to raise_error
      end
    end
  end

  describe PageComplexity::Page do
    let(:analysis) { {} }
    let(:text) { "Sample text" }
    let(:url) { "https://example.com" }

    let(:page) { PageComplexity::Page.new(analysis: analysis, text: text, url: url) }

    describe "#initialize" do
      it "initializes a Page instance" do
        expect(page.analysis).to eq(analysis)
        expect(page.text).to eq(text)
        expect(page.url).to eq(url)
      end
    end
  end
end
