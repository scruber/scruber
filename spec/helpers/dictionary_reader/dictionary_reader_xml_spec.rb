require "spec_helper"

RSpec.describe Scruber::Helpers::DictionaryReader::Xml do

  describe "register" do
    it "should correctly read first element" do
      cl = described_class.new(File.expand_path(File.dirname(__FILE__))+'/dict.xml')

      result = nil
      cl.read do |obj|
        result = obj
      end
      expect(result.sort).to eq({"r10"=>"true", "country"=>"US", "state"=>"NY", "postal_code"=>"10002"}.sort)
    end

    it "should correctly read first element with different selector" do
      cl = described_class.new(File.expand_path(File.dirname(__FILE__))+'/dict_records.xml')

      result = nil
      cl.read(selector: 'record') do |obj|
        result = obj
      end
      expect(result.sort).to eq({"r10"=>"true", "country"=>"US", "state"=>"NY", "postal_code"=>"10002"}.sort)
    end

    it "should read 3 elements total" do
      cl = described_class.new(File.expand_path(File.dirname(__FILE__))+'/dict.xml')

      count = 0
      cl.read do |obj|
        count += 1
      end
      expect(count).to eq(3)
    end

    it "should read 1 elements with state=WI" do
      cl = described_class.new(File.expand_path(File.dirname(__FILE__))+'/dict.xml')

      results = []
      cl.read({state: 'WI'}) do |obj|
        results.push obj.sort
      end
      expect(results).to eq([{"r10"=>"false", "country"=>"US", "state"=>"WI", "postal_code"=>"54914"}.sort])
    end
  end
end
