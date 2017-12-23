module Crawley
  module Core
    module PageFormat
      class HTML < Base
        def self.process(page)
          Nokogiri::HTML(page.response_body) rescue nil
        end
      end
    end
  end
end

Crawley::Core::PageFormat.add(:html, Crawley::Core::PageFormat::HTML)