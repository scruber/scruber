module Crawley
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
    end
  end
end