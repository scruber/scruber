module Crawley
  module Core
    class Configuration
      attr_accessor :fetcher, :queue_driver, :fetcher_options, :queue_driver_options

      def initialize
        @fetcher = :typhoeus_fetcher
        @queue_driver = :simple
        @fetcher_options = {}
        @queue_driver_options = {}
      end

      # class << self
      #   def configure
      #     yield self.new
      #   end
      # end
    end
  end
end