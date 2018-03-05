module Scruber
  module Fetcher
    class << self
      attr_writer :adapter

      def new(options={})
        adapter.new(::Scruber.configuration.fetcher_options.merge(options))
      end

      def adapter
        unless @adapter
          @adapter = ::Scruber.configuration.fetcher_adapter || _adapters.keys.first
        end
        raise Scruber::ArgumentError.new("Adapter not found") unless @adapter
        _adapters[@adapter]
      end

      def add_adapter(label, claz)
        unless claz.method_defined?(:run)
          raise NoMethodError, "run is not declared in the #{label.inspect}"
        end
        _adapters[label] = claz
      end

      def [](label)
        _adapters[label]
      end

      def _adapters
        @_adapters ||= {}
      end
    end
  end
end