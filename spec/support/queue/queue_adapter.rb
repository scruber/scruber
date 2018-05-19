require "spec_helper"

RSpec.shared_examples "queue_adapter" do

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

  describe "processing errors page" do
    it "should fetch error page" do
      queue.add "http://example.com"
      page = queue.fetch_pending
      page.retry_count = 5
      page.max_retry_times = 5
      page.save
      error_page = queue.fetch_error
      expect(error_page).not_to eq(nil)
      expect(error_page.id).to eq(page.id)
    end

    it "should return page to downloading" do
      queue.add "http://example.com"
      page = queue.fetch_pending
      page.retry_count = 5
      page.max_retry_times = 5
      page.save
      error_page = queue.fetch_error
      error_page.redownload!(0)
      pending_page = queue.fetch_pending
      err_page = queue.fetch_error
      d_page = queue.fetch_downloaded
      expect(error_page.id).to eq(pending_page.id)
      expect(err_page).to be_nil
      expect(d_page).to be_nil
    end

    it "should delete page from queue" do
      queue.add "http://example.com"
      page = queue.fetch_pending
      page.retry_count = 5
      page.max_retry_times = 5
      page.save
      error_page = queue.fetch_error
      error_page.delete
      pending_page = queue.fetch_pending
      err_page = queue.fetch_error
      d_page = queue.fetch_downloaded
      expect(pending_page).to be_nil
      expect(err_page).to be_nil
      expect(d_page).to be_nil
    end

    it "should process page" do
      queue.add "http://example.com"
      page = queue.fetch_pending
      page.retry_count = 5
      page.max_retry_times = 5
      page.save
      error_page = queue.fetch_error
      error_page.processed!
      pending_page = queue.fetch_pending
      err_page = queue.fetch_error
      d_page = queue.fetch_downloaded
      expect(pending_page).to be_nil
      expect(err_page).to be_nil
      expect(d_page).to be_nil
      queue.add "http://example.com"
      pending_page = queue.fetch_pending
      expect(pending_page).to be_nil
    end
  end

  context "#add" do
    it "queue page for downloading" do
      queue.add "http://example.com"
      expect(queue.size).to eq(1)
    end

    it "should not add the same page twice" do
      queue.add "http://example.com"
      expect(queue.size).to eq(1)
      queue.add "http://example.com"
      expect(queue.size).to eq(1)
    end

    it "should not add the same page twice even if page was processed" do
      queue.add "http://example.com"
      page = queue.fetch_pending
      page.fetched_at = Time.now.to_i
      page.save
      downloaded_page = queue.fetch_downloaded
      downloaded_page.processed!
      queue.add "http://example.com"
      page = queue.fetch_pending
      expect(page).to eq(nil)
    end
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

    it "should save additional arguments" do
      queue.add "http://example.abc", id: 'abc', test_id: '1'
      page = queue.find 'abc'
      
      expect(page.options[:test_id]).to eq('1')
    end

    it "should not override page" do
      queue.add "http://example.abc", id: 'abc'
      page = queue.find 'abc'
      page.fetched_at = 1
      page.save
      page = queue.find 'abc'
      expect(page.fetched_at).to eq(1)
      queue.add "http://example.abc", id: 'abc'
      page = queue.find 'abc'
      expect(page.fetched_at).to eq(1)
    end
  end

  context "#processed!" do
    it "should update page and set processed_at" do
      queue.add "http://example.com"
      page = queue.fetch_pending
      page.fetched_at = Time.now.to_i
      page.save
      downloaded_page = queue.fetch_downloaded
      downloaded_page.processed!
      downloaded_page2 = queue.fetch_downloaded
      expect(downloaded_page2).to eq(nil)
      expect(downloaded_page.processed_at).to be >= 0
    end
  end

  describe "Page" do
    let(:page_class){ described_class.const_get(:Page) }

    it "should generate different ids for different urls" do
      page1 = page_class.new queue, url: "http://example.com/product1"
      page2 = page_class.new queue, url: "http://example.com/product2"
      expect(page1.id).not_to be_blank
      expect(page1.id).not_to eq(page2.id)
    end

    it "should join url" do
      page1 = page_class.new queue, url: "http://example.com/product1"
      expect(page1.url_join('/abc')).to eq("http://example.com/abc")
    end
  end
end
