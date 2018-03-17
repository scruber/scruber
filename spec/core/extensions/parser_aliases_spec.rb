require "spec_helper"

RSpec.describe Scruber::Core::Extensions::ParserAliases do

  describe "register" do
    it "should extend Crawler with parse and parse_* methods" do
      described_class.register

      expect(Scruber::Core::Crawler.method_defined?(:parse)).to be_truthy
      expect(Scruber::Core::Crawler._registered_method_missings.keys.include?(/\Aparse_(\w+)\Z/)).to be_truthy
      expect(Scruber::Core::Crawler.new(:sample).respond_to?(:parse_product)).to be_truthy
    end
  end

  describe "#parse" do
    context "without format" do
      it "should register parser" do
        described_class.register

        stub_request(:get, "http://example.com").to_return(body: 'Example Domain')

        Scruber.run :sample do
          get "http://example.com"
          
          parse do |page|
            $page = page
          end
        end
        expect($page.url).to eq("http://example.com")
        expect($page.page_type.to_s).to eq("seed")
      end

      it "should register parser with custom page_type" do
        described_class.register

        stub_request(:post, "http://example.com").to_return(body: 'Example Domain')

        Scruber.run :sample do
          post_product "http://example.com"
          
          parse_product do |page|
            $page = page
          end
        end
        expect($page.url).to eq("http://example.com")
        expect($page.method.to_s).to eq("post")
        expect($page.page_type.to_s).to eq("product")
      end
    end

    context "with format" do
      it "should register parser" do
        described_class.register

        stub_request(:get, "http://example.com").to_return(body: '<div><span>Example Domain</span></div>')

        Scruber.run :sample do
          get "http://example.com"
          
          parse :html do |page,doc|
            $page = page
            $doc = doc
          end
        end
        expect($doc.at('span').text).to eq("Example Domain")
        expect($page.page_type.to_s).to eq("seed")
        expect($page.method.to_s).to eq("get")
      end

      it "should register parser with custom page_type" do
        described_class.register

        stub_request(:post, "http://example.com").to_return(body: '<div><span>Example Post</span></div>')

        Scruber.run :sample do
          post_product "http://example.com"
          
          parse_product :html do |page,doc|
            $page = page
            $doc = doc
          end
        end
        expect($doc.at('span').text).to eq("Example Post")
        expect($page.method.to_s).to eq("post")
        expect($page.page_type.to_s).to eq("product")
      end
    end
  end
end
