require "spec_helper"

RSpec.describe Crawley::QueueDriver::Simple do
  let(:queue){ described_class.new }

  it "queue page for downloading" do
    queue.add "http://example.com"
    expect(queue.queue_size).to eq(1)
  end

  it "shift first enqueued page" do
    queue.add "http://example.com"
    queue.add "http://example2.com"
    page = queue.shift_for_fetching
    expect(page.url).to eq("http://example.com")
  end
end
