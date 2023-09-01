# frozen_string_literal: true

RSpec.describe PageComplexity do
  it "has a version number" do
    expect(PageComplexity::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end

  it "returns a hash of metrics" do
    text = "This is a test"
    result = PageComplexity.analyze(text: text)
    expect(result).to be_a Hash
  end
end
