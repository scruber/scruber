require "spec_helper"

RSpec.describe Scruber::Core::Extensions::CsvOutput do

  describe "register" do
    it "should extend Scruber::CsvOutput with csv_file and csv_out method" do
      described_class.register

      expect(Scruber::Core::Crawler.method_defined?(:csv_file)).to be_truthy
      expect(Scruber::Core::Crawler.method_defined?(:csv_out)).to be_truthy
      expect(Scruber::Core::Crawler._registered_method_missings.keys.include?(/\Acsv_(\w+)_file\Z/)).to be_truthy
      expect(Scruber::Core::Crawler.new.respond_to?(:csv_products_file)).to be_truthy
    end
  end

  describe "csv_file" do
    it "should create csv_file and write output" do
      described_class.register
      csv_file_name = File.join(File.expand_path(File.dirname(__FILE__)), 'test.csv')

      Scruber.run do
        csv_file csv_file_name, col_sep: '|'
        csv_out [1,2,3]
      end
      expect(File.exists?(csv_file_name)).to be_truthy
      expect(File.open(csv_file_name, 'r'){|f| f.read }.strip).to eq('1|2|3')
      File.delete(csv_file_name) if File.exists?(csv_file_name)
    end
  end

  describe "csv_{pattern}_file" do
    it "should register file and write output" do
      described_class.register
      csv_file_name = File.join(File.expand_path(File.dirname(__FILE__)), 'products.csv')
      Scruber.run do
        csv_products_file csv_file_name, col_sep: '|'
        csv_products_out [1,2,3]
      end
      expect(File.exists?(csv_file_name)).to be_truthy
      expect(File.open(csv_file_name, 'r'){|f| f.read }.strip).to eq('1|2|3')
      File.delete(csv_file_name) if File.exists?(csv_file_name)
    end
  end
end
