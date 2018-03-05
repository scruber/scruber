module Scruber
  module Core
    class Configuration
      attr_accessor :fetcher_adapter,
                    :fetcher_options,
                    :fetcher_agent_adapter,
                    :fetcher_agent_options,
                    :queue_adapter,
                    :queue_options

      def initialize
        @fetcher_adapter = :typhoeus_fetcher
        @fetcher_options = {}
        @fetcher_agent_adapter = :memory
        @fetcher_agent_options = {}
        @queue_adapter = :memory
        @queue_options = {}
      end

      def merge_options(options)
        @fetcher_adapter = options.fetch(:fetcher_adapter){ @fetcher_adapter }
        @fetcher_options.merge! options.fetch(:fetcher_options){ {} }
        @fetcher_agent_adapter = options.fetch(:fetcher_agent_adapter){ @fetcher_agent_adapter }
        @fetcher_agent_options.merge! options.fetch(:fetcher_agent_options){ {} }
        @queue_adapter = options.fetch(:queue_adapter){ @queue_adapter }
        @queue_options.merge! options.fetch(:queue_options){ {} }
      end
    end
  end
end