module Crawley
  module Helpers
    module FetcherAgent
      class << self
        attr_writer :adapter

        def new(options={})
          adapter.new(::Crawley.configuration.fetcher_agent_options.merge(options))
        end

        def find(id)
          adapter.find(id)
        end

        def adapter
          unless @adapter
            @adapter = ::Crawley.configuration.fetcher_agent_adapter || _adapters.keys.first
          end
          raise Crawley::ArgumentError.new("Adapter not found") unless @adapter
          _adapters[@adapter]
        end

        def add_adapter(label, claz)
          # unless claz.method_defined?(:run)
          #   raise NoMethodError, "run is not declared in the #{label.inspect}"
          # end
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
end
