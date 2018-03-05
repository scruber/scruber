module Scruber
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

Scruber::Core::PageFormat.add(:html, Scruber::Core::PageFormat::HTML)