require "spec_helper"

RSpec.describe Scruber::Helpers::UserAgentRotator::UserAgent do

  describe "user_agent" do
    let(:user_agent) { described_class.new('Scruber 1.0', tags: [:robot, :scruber]) }

    it 'should have valid id' do
      expect(user_agent.id).to eq('Scruber 1.0')
    end

    it 'should have valid tags' do
      expect(user_agent.tags).to eq([:robot, :scruber])
    end

    it 'should always have array of tags' do
      ua = described_class.new('Scruber 1.0')
      expect(ua.tags).to eq([])

      ua = described_class.new('Scruber 1.0', tags: nil)
      expect(ua.tags).to eq([])

      ua = described_class.new('Scruber 1.0', tags: :robot)
      expect(ua.tags).to eq([:robot])
    end

    it 'should always have array of symbolic tags' do
      ua = described_class.new('Scruber 1.0', tags: 'robot')
      expect(ua.tags).to eq([:robot])

      ua = described_class.new('Scruber 1.0', tags: ['robot', 'scruber'])
      expect(ua.tags).to eq([:robot, :scruber])
    end

    it 'should raise error if port or address not given' do
      expect{ described_class.new('') }.to raise_error(Scruber::ArgumentError)
    end
  end

end
