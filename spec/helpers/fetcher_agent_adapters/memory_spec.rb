require "spec_helper"

RSpec.describe Scruber::Helpers::FetcherAgentAdapters::Memory do

  let(:cookie_jar_string) { "---\n- !ruby/object:HTTP::Cookie\n  name: feed_flow\n  value: top\n  domain: example.com\n  for_domain: false\n  path: \"/\"\n  secure: false\n  httponly: true\n  expires: \n  max_age: 26784000\n  created_at: #{Time.now.strftime('%Y-%m-%d')} 16:46:15.443984000 +03:00\n  accessed_at: #{Time.now.strftime('%Y-%m-%d')} 16:47:07.047296000 +03:00\n" }

  let(:agent) do
    described_class.new user_agent: 'Scruber',
                        proxy_id: 1,
                        headers: {'a' => 1},
                        cookie_jar: cookie_jar_string,
                        disable_proxy: true
  end

  describe "initialize" do
    it "should generate id" do
      expect(agent.id).not_to be_nil
    end
  end

  describe "save" do
    it "should be stored to memory collection" do
      agent.save
      expect(Scruber::Helpers::FetcherAgentAdapters::Memory._collection[agent.id]).to eq(agent)
    end
  end

  describe "delete" do
    it "should be deleted from memory collection" do
      agent.save
      expect(Scruber::Helpers::FetcherAgentAdapters::Memory._collection[agent.id]).to eq(agent)
      agent.delete
      expect(Scruber::Helpers::FetcherAgentAdapters::Memory._collection[agent.id]).to be_nil
    end
  end

  describe "class methods" do
    describe "find" do
      it "should find agent by id" do
        agent.save
        expect(Scruber::Helpers::FetcherAgentAdapters::Memory.find(agent.id)).to eq(agent)
      end
    end
  end
end
