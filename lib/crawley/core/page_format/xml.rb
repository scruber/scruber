module Crawley
  module Core
    module PageFormat
      class XML < Base
        def self.process(page)
          Nokogiri.parse(page.response_body) rescue nil
        end
      end
    end
  end
end

Crawley::Core::PageFormat.add(:xml, Crawley::Core::PageFormat::XML)