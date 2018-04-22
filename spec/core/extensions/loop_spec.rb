require "spec_helper"

RSpec.describe Scruber::Core::Extensions::Loop do

  describe "register" do
    it "should extend Scruber::Core with loop method" do
      described_class.register

      expect(Scruber::Core::Crawler.method_defined?(:loop)).to be_truthy
    end

    it "should add dictionary and read info" do
      Scruber::Core::Extensions::Loop.register
      $zip_codes = []
      Scruber.run :sample do
        add_dictionary :zip_codes_usa, File.expand_path(File.dirname(__FILE__))+'/dict.csv', :csv
        seed do
          loop :zip_codes_usa, state: 'NY' do |row|
            $zip_codes.push row['zip']
          end
        end
      end
      expect($zip_codes).to eq(['10001', '10002'])
    end
  end
end
