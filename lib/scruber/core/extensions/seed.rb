module Scruber
  module Core
    module Extensions
      class Seed < Base
        module CoreMethods
          def seed(&block)
            unless queue.initialized?
              instance_exec &block
            end
          end
        end
      end
    end
  end
end
