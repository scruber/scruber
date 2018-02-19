require "spec_helper"

RSpec.describe Crawley::Fetcher do

  describe "add_adapter" do
    it "should raise error" do
      expect{ described_class.add_adapter(:obj, Object) }.to raise_error(NoMethodError)
    end

    it "should add new adapter and return added class" do
      expect(described_class.add_adapter(:typhoeus_fetcher, Crawley::FetcherAdapters::TyphoeusFetcher)).to eq(Crawley::FetcherAdapters::TyphoeusFetcher)
      expect(described_class._adapters.keys).to include(:typhoeus_fetcher)
    end
  end

  describe "adapter" do
    it "should return default adapter" do
      expect(described_class.adapter).to eq(Crawley::FetcherAdapters::TyphoeusFetcher)
    end
  end

  describe "new" do
    it "should return instance of default adapter" do
      expect(described_class.new).to be_a(Crawley::FetcherAdapters::TyphoeusFetcher)
    end
  end
end
