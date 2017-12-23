module Crawley
  module Core
    module PageFormat
      class Base
        def self.process(page)
          raise NotImplementedError
        end
      end
    end
  end
end