module Scruber
  module Core
    module Extensions

      # 
      # Seed DSL
      # Seed block executes only when queue was not initialized yet
      # (queue has no any page, processed or pending)
      # 
      # @author Ivan Goncharov
      # 
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
