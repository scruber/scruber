require "spec_helper"

RSpec.describe Crawley::Queue do

  describe "add_adapter" do
    it "should raise error" do
      expect{ described_class.add_adapter(:obj, Object) }.to raise_error(NoMethodError)
    end

    it "should add new adapter and return added class" do
      expect(described_class.add_adapter(:simple2, Crawley::QueueAdapter::Simple)).to eq(Crawley::QueueAdapter::Simple)
      expect(described_class._adapters.keys).to include(:simple2)
    end
  end

  describe "adapter" do
    it "should return default adapter" do
      expect(described_class.adapter).to eq(Crawley::QueueAdapter::Simple)
    end
  end

  describe "new" do
    it "should return instance of default adapter" do
      expect(described_class.new).to be_a(Crawley::QueueAdapter::Simple)
    end
  end
end
