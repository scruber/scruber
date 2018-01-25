module Crawley
  module Core
    class Configuration
      attr_accessor :fetcher_driver, :queue_driver, :fetcher_options, :queue_options

      def initialize
        @fetcher_driver = :typhoeus_fetcher
        @queue_driver = :simple
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