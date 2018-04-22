require "spec_helper"

RSpec.describe Scruber::Core::Extensions::Log do

  describe "register" do
    it "should extend Scruber::Core with log method" do
      described_class.register

      expect(Scruber::Core::Crawler.method_defined?(:log)).to be_truthy
    end
  end

  describe "#log" do
    let(:log_file) { Pathname.new(File.expand_path('../log.txt', __FILE__)) }
    before { Scruber.logger = Logger.new(log_file)  }
    after{ (File.delete(log_file) rescue nil) }

    it "should write log to file" do
      Scruber.run :sample, silent: true do
        log "Seeding"
      end
      expect(File.open(log_file){|f| f.read}).to match(/Seeding/)
    end
  end
end
