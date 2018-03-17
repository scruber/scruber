module Scruber
  module Core
    module PageFormat
      class XML < Base
        def self.process(page)
          Nokogiri::XML(page.response_body) rescue nil
        end
      end
    end
  end
end

Scruber::Core::PageFormat.add(:xml, Scruber::Core::PageFormat::XML)