require "spec_helper"

RSpec.describe Scruber::Helpers::ProxyRotator::Proxy do

  describe "proxy" do
    let(:proxy) { described_class.new('127.0.0.1:3000', :user=>'user', :password=>'password', :probability=>1, :type=>'socks') }

    it 'should have valid id' do
      proxy = described_class.new('127.0.0.1:3000')
      expect(proxy.id).to eq('127.0.0.1:3000')
      proxy = described_class.new('127.0.0.1', port: 3001)
      expect(proxy.id).to eq('127.0.0.1:3001')
    end

    it 'should raise error if port or address not given' do
      expect{ described_class.new('127.0.0.1') }.to raise_error(Scruber::ArgumentError)
      expect{ described_class.new('', port: 3000) }.to raise_error(Scruber::ArgumentError)
    end
  end

end
