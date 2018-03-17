require "spec_helper"

RSpec.describe Scruber::Core::Extensions::QueueAliases do

  describe "register" do
    it "should extend Crawler with get,post,head and (get|post|head)_* methods" do
      described_class.register

      expect(Scruber::Core::Crawler.method_defined?(:get)).to be_truthy
      expect(Scruber::Core::Crawler.method_defined?(:head)).to be_truthy
      expect(Scruber::Core::Crawler.method_defined?(:post)).to be_truthy
      expect(Scruber::Core::Crawler._registered_method_missings.keys.include?(/\A(get|post|head)_(\w+)\Z/)).to be_truthy
      expect(Scruber::Core::Crawler.new(:sample).respond_to?(:get_product)).to be_truthy
    end
  end

  describe "#get,#post" do
    context "without options" do
      it "should add page to queue" do
        described_class.register

        Scruber.run :sample do
          get "http://example.com"
          $page = queue.fetch_pending
        end
        expect($page.url).to eq("http://example.com")
        expect($page.method.to_s).to eq("get")
        expect($page.page_type.to_s).to eq("seed")
      end

      it "should add page to queue" do
        described_class.register

        Scruber.run :sample do
          post_product "http://example.com"
          $page = queue.fetch_pending
        end
        expect($page.url).to eq("http://example.com")
        expect($page.method.to_s).to eq("post")
        expect($page.page_type).to eq("product")
      end
    end

    context "with options" do
      it "should add page to queue" do
        described_class.register

        Scruber.run :sample do
          get "http://example.com", user_agent: 'Agent 1'
          $page = queue.fetch_pending
        end
        expect($page.url).to eq("http://example.com")
        expect($page.method.to_s).to eq("get")
        expect($page.page_type.to_s).to eq("seed")
        expect($page.user_agent).to eq('Agent 1')
      end

      it "should add page to queue" do
        described_class.register

        Scruber.run :sample do
          post_product "http://example.com", user_agent: 'Agent 1'
          $page = queue.fetch_pending
        end
        expect($page.url).to eq("http://example.com")
        expect($page.method.to_s).to eq("post")
        expect($page.page_type).to eq("product")
        expect($page.user_agent).to eq('Agent 1')
      end
    end
  end
end
