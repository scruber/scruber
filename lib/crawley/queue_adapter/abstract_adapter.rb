module Crawley
  module QueueAdapter
    class AbstractAdapter
      def initialize(options={})
        @options = options
      end

      def enqueue(url, options={})
        raise NotImplementedError
      end

      def shift
        raise NotImplementedError
      end
    end
  end
end