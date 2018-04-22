module Scruber
  module Core
    module Extensions
      # 
      # Base class for extensions
      # @abstract
      # 
      # @author [revis0r]
      # 
      class Base
        module CoreMethods

        end

        class << self
          # 
          # Register extension in crawler core
          # 
          # @return [void]
          def register
            Scruber::Core::Crawler.include self.const_get(:CoreMethods)
          end

          def inherited(subclass)
            @descendants ||= []
            @descendants << subclass
          end

          def descendants
            @descendants 
          end
        end
      end
    end
  end
end