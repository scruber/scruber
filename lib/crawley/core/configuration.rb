module Crawley
  module Core
    class Configuration
      attr_accessor :fetcher_driver, :queue_adapter, :fetcher_options, :queue_options

      def initialize
        @fetcher_driver = :typhoeus_fetcher
        @queue_adapter = :simple
        @fetcher_options = {}
        @queue_options = {}
      end

      # class << self
      #   def configure
      #     yield self.new
      #   end
      # end
    end
  end
end