require "spec_helper"

RSpec.describe Crawley do
  it "has a version number" do
    expect(Crawley::VERSION).not_to be nil
  end

  describe "configurable" do
    before do
      Crawley.configure do |config|
        config.fetcher = :typhoeus_fetcher
      end
    end
    
    it "returns :typhoeus_fetcher as fetcher" do
      expect(Crawley.configuration.fetcher).to eq(:typhoeus_fetcher)
    end
  end

  describe "run" do
    it "simple example" do
      stub_request(:get, "http://example.com").to_return(body: 'Example Domain')

      Crawley.run do
        queue.add "http://example.com"
        
        parser :seed do |page|
          $title = page.response_body
        end
      end
      expect($title).to eq('Example Domain')
    end

    it "should return Nokogiri object" do
      stub_request(:get, "http://example.com/contacts.html").to_return(body: '<div><a>Contacts</a></div>')

      Crawley.run do
        queue.add "http://example.com/contacts.html"
        
        parser :seed, page_format: :html do |page, html|
          $title = html.at('a').text
        end
      end
      expect($title).to eq('Contacts')
    end
  end
end
