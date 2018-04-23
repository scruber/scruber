require "spec_helper"

RSpec.describe Scruber do
  before do
    Scruber::Helpers::UserAgentRotator.configure do
      clean
      set_filter :all
      add "Scruber 1.0", tags: [:robot, :scruber]
      add "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36", tags: [:desktop, :chrome, :macos]
    end
  end

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

    context "complex example" do
      it "should parse pages in 2 steps" do
        stub_request(:get, "http://example.com/catalog").to_return(body: '<div><a href="/product1">Product 1</a><a href="/product2">Product 2</a><a href="/product3">Product 3</a></div>')
        stub_request(:get, "http://example.com/product1").to_return(body: '<div><h1>Product 1</h1></div>')
        stub_request(:get, "http://example.com/product2").to_return(body: '<div><h1>Product 2</h1></div>')
        stub_request(:get, "http://example.com/product3").to_return(body: '<div><h1>Product 3</h1></div>')

        $products = []
        Scruber.run :sample do
          get "http://example.com/catalog"
          
          parse :html do |page, doc|
            doc.search('a').each do |a|
              get_product URI.join(page.url, a.attr('href')).to_s
            end
          end

          parse_product :html do |page,doc|
            $products.push doc.at('h1').text
          end
        end
        expect($products.sort).to eq((1..3).map{|i| "Product #{i}"}.sort)
      end

      it "should redownload page and increase retry" do
        stub_request(:get, "http://example.com/").to_return(body: '<div>blocked</div>').times(2).then.to_return(body: '<div><h1>Product</h1></div>')

        Scruber.run :sample do
          get "http://example.com/"
          
          parse :html do |page, doc|
            if page.response_body =~ /blocked/
              page.redownload!
            else
              $title = doc.at('h1').text
              $retry_count = page.retry_count
            end
          end
        end
        expect($title).to eq('Product')
        expect($retry_count).to eq(2)
      end
    end

    context "processing error examples" do
      it "should process 500 error page" do
        stub_request(:get, "http://example.com").to_return(body: '<div><h1>500</h1></div>', status: 500)

        $error_title = nil
        Scruber.run :sample do
          get "http://example.com", max_retry_times: 1

          parse :html do |page,doc|
            $error_title = doc.at('h1').text
          end

          on_page_error do |page|
            $error_title = page.response_body
            page.processed!
          end
        end
        expect($error_title).to eq('<div><h1>500</h1></div>')
      end

      it "should process 404 error page" do
        stub_request(:get, "http://example.com").to_return(body: '<div><h1>404</h1></div>', status: 404)

        $error_title = nil
        Scruber.run :sample do
          get "http://example.com", max_retry_times: 1

          parse :html do |page,doc|
            $error_title = doc.at('h1').text
          end

          on_page_error do |page|
            $error_title = page.response_body
            page.processed!
          end
        end
        expect($error_title).to eq('<div><h1>404</h1></div>')
      end
    end
  end

  describe "#root" do
    it "should return nil without APP_PATH defined" do
      expect(Scruber.root).to eq(nil)
    end

    it "should return path object" do
      APP_PATH='/tmp/a/b/'
      expect(Scruber.root.to_s).to eq('/tmp')
    end
  end
end
