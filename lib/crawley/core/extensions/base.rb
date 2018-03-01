module Crawley
  module Core
    module Extensions
      class Base
        module CoreMethods

        end

        class << self
          def register
            Crawley::Core::Crawler.include self.const_get(:CoreMethods)
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