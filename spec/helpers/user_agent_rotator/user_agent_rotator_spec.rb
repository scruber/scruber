require "spec_helper"

RSpec.describe Scruber::Helpers::UserAgentRotator do

  describe "configurable" do
    context "with block" do
      before do
        described_class.configure do
          clean
          set_filter :all

          add "Scruber 1.0", tags: [:robot, :scruber]
          add "GoogleBot 1.0", tags: [:robot, :google]
          add "Chrome 1.0", tags: [:desktop, :chrome]
          add "Android 1.0", tags: [:mobile, :android]
        end
      end
      
      it "adds 4 user agents to list" do
        expect(described_class.configuration.user_agents.count).to eq(4)
      end

      it "clean proxies list" do
        described_class.configure do
          clean
        end
        expect(described_class.configuration.user_agents.count).to eq(0)
      end

      it "should have all filter by default" do
        expect(described_class.configuration.tags).to eq(:all)
      end

      it "should set different filter" do
        described_class.configure do
          set_filter :desktop
        end
        expect(described_class.configuration.tags).to eq(:desktop)
      end
    end

    context "with dictionary" do
      before do
        Scruber::Core::Extensions::Loop.add_dictionary(:default_user_agents, File.expand_path(File.dirname(__FILE__))+'/user_agents.xml', :xml)
        
        described_class.configure do
          clean
          set_filter :all

          loop :default_user_agents do |ua|
            add ua['name'], tags: ua['tags'].split(',').map(&:strip)
          end
        end
      end
      
      it "adds 4 user agents to list" do
        expect(described_class.configuration.user_agents.count).to eq(4)
      end

      it "clean proxies list" do
        described_class.configure do
          clean
        end
        expect(described_class.configuration.user_agents.count).to eq(0)
      end

      it "should have all filter by default" do
        expect(described_class.configuration.tags).to eq(:all)
      end

      it "should set different filter" do
        described_class.configure do
          set_filter :desktop
        end
        expect(described_class.configuration.tags).to eq(:desktop)
      end
    end
  end

  describe "with default config" do
    before do
      described_class.configure do
        clean
        set_filter :all

        add "Scruber 1.0", tags: [:robot, :scruber]
        add "GoogleBot 1.0", tags: [:robot, :google]
        add "Chrome 1.0", tags: [:desktop, :chrome]
        add "Android 1.0", tags: [:mobile, :android]
      end
    end

    it "should return all 4 user agents" do
      expect(4.times.map{ described_class.next }.sort).to eq(["Scruber 1.0","GoogleBot 1.0","Chrome 1.0","Android 1.0"].sort)
    end

    it "should return all 4 user agents twice" do
      expect(8.times.map{ described_class.next }.sort).to eq(["Scruber 1.0","GoogleBot 1.0","Chrome 1.0","Android 1.0","Scruber 1.0","GoogleBot 1.0","Chrome 1.0","Android 1.0"].sort)
    end

    it "should return only robot user agents" do
      described_class.configure do
        set_filter :robot
      end
      expect(4.times.map{ described_class.next }.sort).to eq(["Scruber 1.0","GoogleBot 1.0","Scruber 1.0","GoogleBot 1.0"].sort)
    end

    it "should return only desktop chrome" do
      described_class.configure do
        set_filter [:desktop, :chrome]
      end
      expect(2.times.map{ described_class.next }.sort).to eq(["Chrome 1.0", "Chrome 1.0"].sort)
    end
  end

  describe "with passed config" do
    before do
      described_class.configure do
        clean
        set_filter :bad

        add "Scruber 1.0", tags: [:robot, :scruber]
        add "GoogleBot 1.0", tags: [:robot, :google]
        add "Chrome 1.0", tags: [:desktop, :chrome]
        add "Android 1.0", tags: [:mobile, :android]
      end
    end

    it "should return all 4 user agents" do
      expect(4.times.map{ described_class.next(:all) }.sort).to eq(["Scruber 1.0","GoogleBot 1.0","Chrome 1.0","Android 1.0"].sort)
    end

    it "should return all 4 user agents twice" do
      expect(8.times.map{ described_class.next(:all) }.sort).to eq(["Scruber 1.0","GoogleBot 1.0","Chrome 1.0","Android 1.0","Scruber 1.0","GoogleBot 1.0","Chrome 1.0","Android 1.0"].sort)
    end

    it "should return only robot user agents" do
      expect(4.times.map{ described_class.next(:robot) }.sort).to eq(["Scruber 1.0","GoogleBot 1.0","Scruber 1.0","GoogleBot 1.0"].sort)
    end

    it "should return only desktop chrome" do
      expect(2.times.map{ described_class.next([:desktop, :chrome]) }.sort).to eq(["Chrome 1.0", "Chrome 1.0"].sort)
    end
  end
end
