require "spec_helper"

RSpec.describe Crawley::Helpers::ProxyRotator do

  describe "configurable" do
    before do
      described_class.configure do
        set_mode :random

        add "127.0.0.1:3000"
        add "127.0.0.1", port: 3001
      end
    end
    
    it "adds 2 proxies to list" do
      expect(described_class.configuration.proxies.count).to eq(2)
    end

    it "clean proxies list" do
      described_class.configure do
        clean
      end
      expect(described_class.configuration.proxies.count).to eq(0)
    end

    it "should have random mode by default" do
      expect(described_class.configuration.mode).to eq(:random)
    end

    it "should raise error when set incorrect mode" do
      expect{ described_class.configure { set_mode :bad } }.to raise_error(Crawley::ArgumentError)
    end

    it "should build proxy_keys" do
      described_class.configure do
        clean
        set_mode :round_robin

        add "127.0.0.1:3000"
        add "127.0.0.1", port: 3001
      end
      expect(described_class.configuration.proxy_keys.sort).to eq(["127.0.0.1:3000", "127.0.0.1:3001"].sort)
    end

    it "should rebuild proxy_keys" do
      described_class.configure do
        clean
        set_mode :round_robin

        add "127.0.0.1:3000"
        add "127.0.0.1", port: 3001
      end
      expect(described_class.configuration.proxy_keys.sort).to eq(["127.0.0.1:3000", "127.0.0.1:3001"].sort)
      described_class.configure do
        add "127.0.0.5:3000"
      end
      expect(described_class.configuration.proxy_keys.sort).to eq(["127.0.0.1:3000", "127.0.0.1:3001", "127.0.0.5:3000"].sort)
    end
  end

  describe "round_robin mode" do
    before do
      described_class.configure do
        clean
        set_mode :round_robin

        add "127.0.0.1:3000"
        add "127.0.0.2:3000"
        add "127.0.0.3:3000"
      end
    end

    it "should return all 3 proxies" do
      expect(3.times.map{ described_class.next.host }.sort).to eq(["127.0.0.1", "127.0.0.2", "127.0.0.3"].sort)
    end

    it "should return all 3 proxies for random method" do
      expect(3.times.map{ described_class.random.host }.sort).to eq(["127.0.0.1", "127.0.0.2", "127.0.0.3"].sort)
    end

    it "should return all 3 proxies twice" do
      expect(6.times.map{ described_class.next.host }.sort).to eq(["127.0.0.1", "127.0.0.2", "127.0.0.3", "127.0.0.1", "127.0.0.2", "127.0.0.3"].sort)
    end
  end

  describe "random mode" do
    before do
      described_class.configure do
        clean
        set_mode :random

        add "127.0.0.1:3000"
        add "127.0.0.2:3000"
        add "127.0.0.3:3000"
      end
    end

    it "should return all 3 proxies (may raise phantom error)" do
      expect(100.times.map{ described_class.next.host }.uniq.sort).to eq(["127.0.0.1", "127.0.0.2", "127.0.0.3"].sort)
    end

    it "should return 127.0.0.1 more often (may raise phantom error)" do
      described_class.configure do
        clean
        set_mode :random

        add "127.0.0.1:3000", probability: 0.9
        add "127.0.0.2:3000", probability: 0.05
        add "127.0.0.3:3000", probability: 0.05
      end
      expect(100.times.map{ described_class.next.host }.select{|h| h == '127.0.0.1'}.count).to be > 75
    end
  end
end
