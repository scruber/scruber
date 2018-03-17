require "spec_helper"

RSpec.describe Scruber do
  it "has a version number" do
    expect(Scruber::VERSION).not_to be nil
  end

  describe "configurable" do
    before do
      Scruber.configure do |config|
        config.fetcher_adapter = :typhoeus_fetcher
      end
    end
    
    it "returns :typhoeus_fetcher as fetcher" do
      expect(Scruber.configuration.fetcher_adapter).to eq(:typhoeus_fetcher)
    end
  end

  describe "#run" do
    context "without args" do
      it "should raise error" do
        expect { Scruber.run { $title = scraper_name } }.to raise_error(Scruber::ArgumentError)
      end

      it "should set scraper name from ENV" do
        ENV['SCRUBER_SCRAPER_NAME'] = 'sample'
        Scruber.run do
          $scraper_name = scraper_name
        end
        expect($scraper_name).to eq(:sample)
      end
    end

    context "with args" do
      it "should set scraper name from first arg" do
        Scruber.run :sample1 do
          $scraper_name = scraper_name
        end
        expect($scraper_name).to eq(:sample1)
      end

      it "should set scraper name from first arg, and options from second" do
        Scruber.run :sample2, queue_adapter: :test do
          $scraper_name = scraper_name
          $opt = Scruber.configuration.queue_adapter
        end
        expect($scraper_name).to eq(:sample2)
        expect($opt).to eq(:test)
      end

      it "options from first arg and scraper_name from ENV" do
        ENV['SCRUBER_SCRAPER_NAME'] = 'sample'
        Scruber.run queue_adapter: :test2 do
          $scraper_name = scraper_name
          $opt = Scruber.configuration.queue_adapter
        end
        expect($scraper_name).to eq(:sample)
        expect($opt).to eq(:test2)
      end

      it "should raise error if passed only options without ENV" do
        ENV['SCRUBER_SCRAPER_NAME'] = nil
        expect { Scruber.run(queue_adapter: :test2) { $title = scraper_name } }.to raise_error(Scruber::ArgumentError)
      end
    end

    it "simple example" do
      stub_request(:get, "http://example.com").to_return(body: 'Example Domain')

      Scruber.run :sample do
        queue.add "http://example.com"
        
        parser :seed do |page|
          $title = page.response_body
        end
      end
      expect($title).to eq('Example Domain')
    end

    it "should return Nokogiri object" do
      stub_request(:get, "http://example.com/contacts.html").to_return(body: '<div><a>Contacts</a></div>')

      Scruber.run :sample do
        queue.add "http://example.com/contacts.html"
        
        parser :seed, format: :html do |page, html|
          $title = html.at('a').text
        end
      end
      expect($title).to eq('Contacts')
    end
  end
end
