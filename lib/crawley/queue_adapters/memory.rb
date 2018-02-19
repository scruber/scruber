module Crawley
  module QueueAdapters
    class Memory < AbstractAdapter
      attr_reader :error_pages

      def initialize(options={})
        super(options)
        @queue = []
        @downloaded_pages = []
        @error_pages = []
      end

      def push(url_or_page, options={})
        if url_or_page.is_a?(Page)
          @queue.push url_or_page
        else
          @queue.push Page.new(self, url_or_page, options)
        end
      end
      alias_method :add, :push

      def queue_size
        @queue.count
      end

      def shift_for_parsing
        @downloaded_pages.shift
      end

      def shift_for_fetching
        @queue.shift
      end

      def push_for_parsing(page)
        @downloaded_pages.push page
      end

      def puts_error_page(page)
        @error_pages.push page
      end

      def has_work?
        @queue.count > 0 || @downloaded_pages.count > 0
      end

    end
  end
end

Crawley::Queue.add_adapter(:memory, Crawley::QueueAdapters::Memory)