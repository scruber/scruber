module Crawley
  module QueueDriver
    class << self
      def add(label, claz)
        unless claz.method_defined?(:enqueue)
          raise NoMethodError, "enqueue is not declared in the #{label.inspect}"
        end

        _registered_drivers[label] = claz
      end

      def [](label)
        _registered_drivers[label]
      end

      def _registered_drivers
        @registered_drivers ||= {}
      end
    end
  end
end