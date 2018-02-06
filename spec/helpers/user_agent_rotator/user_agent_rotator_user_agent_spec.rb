require "spec_helper"

RSpec.describe Crawley::Helpers::UserAgentRotator::UserAgent do

  describe "user_agent" do
    let(:user_agent) { described_class.new('Crawley 1.0', tags: [:robot, :crawley]) }

    it 'should have valid id' do
      expect(user_agent.id).to eq('Crawley 1.0')
    end

    it 'should have valid tags' do
      expect(user_agent.tags).to eq([:robot, :crawley])
    end

    it 'should always have array of tags' do
      ua = described_class.new('Crawley 1.0')
      expect(ua.tags).to eq([])

      ua = described_class.new('Crawley 1.0', tags: nil)
      expect(ua.tags).to eq([])

      ua = described_class.new('Crawley 1.0', tags: :robot)
      expect(ua.tags).to eq([:robot])
    end

    it 'should always have array of symbolic tags' do
      ua = described_class.new('Crawley 1.0', tags: 'robot')
      expect(ua.tags).to eq([:robot])

      ua = described_class.new('Crawley 1.0', tags: ['robot', 'crawley'])
      expect(ua.tags).to eq([:robot, :crawley])
    end

    it 'should raise error if port or address not given' do
      expect{ described_class.new('') }.to raise_error(Crawley::ArgumentError)
    end
  end

end
