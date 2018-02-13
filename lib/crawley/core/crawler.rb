module Crawley
  module Core
    class Crawler
      attr_reader :queue, :fetcher

      def initialize(options={})
        @callbacks_options = {}
        @callbacks = {}
        @queue = Crawley::Queue.new
        @fetcher = Crawley::Fetcher.new
      end

      # 
      # Run crawling.
      # 
      # @param block [Proc] crawler body
      def run(&block)
        instance_eval &block
        while @queue.has_work? do
          @fetcher.run @queue
          while page = @queue.shift_for_parsing do
            if @callbacks[page.page_type.to_sym]
              processed_page = process_page(page, page.page_type.to_sym)
              instance_exec page, processed_page, &(@callbacks[page.page_type.to_sym])
            end
          end
        end
      end

      def parser(page_type, options={}, &block)
        register_callback(page_type, options, &block)
      end

      private

        def register_callback(page_type, options, &block)
          @callbacks_options[page_type.to_sym] = options || {}
          @callbacks[page_type.to_sym] = block
        end

        def process_page(page, page_type)
          page_format = @callbacks_options[page_type].fetch(:page_format){ nil }
          Crawley::Core::PageFormat.process(page, page_format)
        end
    end
  end
end
