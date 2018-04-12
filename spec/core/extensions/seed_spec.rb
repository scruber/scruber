require "spec_helper"

RSpec.describe Scruber::Core::Extensions::Seed do

  describe "register" do
    it "should extend Scruber::Core with seed method" do
      described_class.register

      expect(Scruber::Core::Crawler.method_defined?(:seed)).to be_truthy
    end
  end

  before do
    stub_request(:get, "http://example.com").to_return(body: '<div><a>Main</a></div>')
    stub_request(:get, "http://example.com/contacts").to_return(body: '<div><a>Contacts</a></div>')
  end
  
  it "should execute seed block" do
    $queue_size = 0
    Scruber.run :sample do
      seed do
        get 'http://example.com'
      end
      $queue_size = queue.size
    end
    expect($queue_size).to eq(1)
  end

  it "should not execute seed block" do
    $queue_size = 0
    Scruber.run :sample do
      seed do
        get 'http://example.com'
      end
      seed do
        get 'http://example.com/contacts'
      end
      $queue_size = queue.size
      $page = queue.fetch_pending
    end
    expect($queue_size).to eq(1)
    expect($page.url).to eq("http://example.com")
  end
end
