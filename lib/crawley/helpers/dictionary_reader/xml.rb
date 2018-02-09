module Crawley
  module Helpers
    module DictionaryReader
      class Xml
        def initialize(file_path)
          @xml = Nokogiri.parse(File.open(file_path).read)
        end

        def read(options={})
          selector = options.delete(:selector) || 'item'
          options.each do |k,v|
            selector = "#{selector}[#{k}=\"#{v}\"]"
          end
          @xml.search(selector).each do |item|
            yield item.to_h
          end
        end
      end
    end
  end
end

Crawley::Helpers::DictionaryReader.add(:xml, Crawley::Helpers::DictionaryReader::Xml)