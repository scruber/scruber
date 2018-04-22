require "spec_helper"

RSpec.describe Scruber::QueueAdapters::Memory do
  let(:queue){ described_class.new }
  
  it_behaves_like "queue_adapter"

  it "shift first enqueued page" do
    queue.add "http://example.com"
    queue.add "http://example2.com"
    page = queue.fetch_pending
    expect(page.url).to eq("http://example.com")
  end

end
