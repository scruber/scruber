module Scruber
  module Core
    # 
    # Configuration class
    # 
    # @author Ivan Goncharov
    # @attr [Symbol] fetcher_adapter Fetcher adapter name
    # @attr [Hash] fetcher_options Fetcher options, see {Scruber::FetcherAdapters::AbstractAdapter} options
    # @attr [Symbol] fetcher_agent_adapter Fetcher agent adapter name
    # @attr [Hash] fetcher_agent_options Fetcher agent options, see {Scruber::Helpers::FetcherAgentAdapters::AbstractAdapter}
    # @attr [Symbol] queue_adapter Queue adapter name
    # @attr [Hash] queue_options Queue options, see {Scruber::QueueAdapters::AbstractAdapter}
    # @attr [Array<String>] autoload_paths Array with paths for autoloading classes
    # @attr [Boolean] silent Don't output anything if true
    class Configuration
      attr_accessor :fetcher_adapter,
                    :fetcher_options,
                    :fetcher_agent_adapter,
                    :fetcher_agent_options,
                    :queue_adapter,
                    :queue_options,
                    :autoload_paths,
                    :silent

      def initialize
        @fetcher_adapter = :typhoeus_fetcher
        @fetcher_options = {}
        @fetcher_agent_adapter = :memory
        @fetcher_agent_options = {}
        @queue_adapter = :memory
        @queue_options = {}
        @autoload_paths = []
        @silent = false
      end

      # 
      # Merge options from hash
      # @param options [Hash] options
      # 
      # @return [void]
      def merge_options(options)
        @fetcher_adapter = options.fetch(:fetcher_adapter){ @fetcher_adapter }
        @fetcher_options.merge! options.fetch(:fetcher_options){ {} }
        @fetcher_agent_adapter = options.fetch(:fetcher_agent_adapter){ @fetcher_agent_adapter }
        @fetcher_agent_options.merge! options.fetch(:fetcher_agent_options){ {} }
        @queue_adapter = options.fetch(:queue_adapter){ @queue_adapter }
        @queue_options.merge! options.fetch(:queue_options){ {} }
        @autoload_paths += options.fetch(:autoload_paths){ [] }
        @silent = options.fetch(:silent){ false }
      end
    end
  end
end