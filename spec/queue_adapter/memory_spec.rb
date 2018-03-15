require "spec_helper"

RSpec.describe Scruber::QueueAdapters::Memory do
  let(:queue){ described_class.new }

  it "queue page for downloading" do
    queue.add "http://example.com"
    expect(queue.queue_size).to eq(1)
  end

  it "shift first enqueued page" do
    queue.add "http://example.com"
    queue.add "http://example2.com"
    page = queue.fetch_pending
    expect(page.url).to eq("http://example.com")
  end

  it "should update page" do
    queue.add "http://example.com"
    page = queue.fetch_pending
    page.url = "http://example.net"
    page.save
    page = queue.fetch_pending
    expect(page.url).to eq("http://example.net")
  end

  it "should update page and fetch downloaded page" do
    queue.add "http://example.com"
    page = queue.fetch_pending
    page.fetched_at = Time.now.to_i
    page.save
    pending_page = queue.fetch_pending
    downloaded_page = queue.fetch_downloaded
    expect(pending_page).to eq(nil)
    expect(downloaded_page.url).to eq("http://example.com")
  end

  context "#save" do
    it "should delete page" do
      queue.add "http://example.abc"
      page = queue.fetch_pending
      page.fetched_at = Time.now.to_i
      page.save
      page.delete
      page = queue.fetch_downloaded
      
      expect(page).to eq(nil)
    end
  end
end
