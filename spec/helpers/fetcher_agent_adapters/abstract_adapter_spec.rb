require "spec_helper"

RSpec.describe Scruber::Helpers::FetcherAgentAdapters::AbstractAdapter do

  let(:cookie_jar_string) { "---\n- !ruby/object:HTTP::Cookie\n  name: feed_flow\n  value: top\n  domain: example.com\n  for_domain: false\n  path: \"/\"\n  secure: false\n  httponly: true\n  expires: \n  max_age: 26784000\n  created_at: #{Time.now.strftime('%Y-%m-%d')} 16:46:15.443984000 +03:00\n  accessed_at: #{Time.now.strftime('%Y-%m-%d')} 16:47:07.047296000 +03:00\n" }

  describe "initialize" do
    let(:agent) do
      described_class.new id: 1,
                          user_agent: 'Scruber',
                          proxy_id: 1,
                          headers: {'a' => 1},
                          cookie_jar: cookie_jar_string,
                          disable_proxy: true
    end
    
    it "set values" do
      expect(agent.id).to eq(1)
      expect(agent.user_agent).to eq('Scruber')
      expect(agent.proxy_id).to eq(1)
      expect(agent.headers).to eq({'a' => 1})
      expect(agent.cookie_jar).to eq(cookie_jar_string)
      expect(agent.disable_proxy).to eq(true)
    end

    it "load cookies" do
      expect(agent.cookie_for('http://example.com')).to eq('feed_flow=top')
      expect(agent.cookie_for(URI('http://example.com'))).to eq('feed_flow=top')
    end

    it "serialize cookie" do
      expect(agent.serialize_cookies).to eq(cookie_jar_string)
    end

    it "parse cookies from page" do
      page = Scruber::QueueAdapters::AbstractAdapter::Page.new(nil, 'http://example.com', response_headers: {"Connection" => "keep-alive","Set-Cookie" => "__cfduid=dc8db498b1e419b7943052a69c8e9d1d01504311966; expires=Sun, 02-Sep-18 00:26:06 GMT; path=/; domain=example.com; HttpOnly"})
      agent.parse_cookies_from_page!(page)
      expect(agent.cookie_for('http://example.com')).to eq('__cfduid=dc8db498b1e419b7943052a69c8e9d1d01504311966; feed_flow=top')
    end

  end

  it "should be accessible from scraper" do
    expect { Scruber.run(:sample) { FetcherAgent } }.not_to raise_error
  end
end
