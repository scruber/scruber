module Crawley
  module Fetcher
    class << self
      def add(label, claz)
        unless claz.method_defined?(:run)
          raise NoMethodError, "run is not declared in the #{label.inspect}"
        end

        _registered_fetchers[label] = claz
      end

      def [](label)
        _registered_fetchers[label]
      end

      def _registered_fetchers
        @registered_fetchers ||= {}
      end
    end
  end
end