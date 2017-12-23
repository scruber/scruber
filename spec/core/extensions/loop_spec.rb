require "spec_helper"

RSpec.describe Crawley::Core::Extensions::Loop do

  describe "register" do
    it "should extend Crawley::Core with loop method" do
      described_class.register

      expect(Crawley::Core::Crawler.method_defined?(:loop)).to be_truthy
    end

    # it "should return Nokogiri object" do
    #   Crawley::Core::Extensions::Loop.register
    #   $title = []
    #   Crawley.run do
    #     loop :postal_codes, r: 10 do |i,o,o2|
    #       $title.push [i,o,o2]
    #     end
    #   end
    #   puts $title
    # end
  end
end
