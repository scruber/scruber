module Scruber
  module QueueAdapters
    class Memory < AbstractAdapter
      attr_reader :error_pages

      class Page < Scruber::QueueAdapters::AbstractAdapter::Page
        def save
          if self.fetched_at > 0
            @queue.add_downloaded self
          elsif self.retry_count >= self.max_retry_times.to_i
            @queue.add_error_page self
          else
            @queue.push self
          end
        end
      end

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

      def fetch_downloaded(count=nil)
        if count.nil?
          @downloaded_pages.shift
        else
          @downloaded_pages.shift(count)
        end
      end

      def fetch_pending(count=nil)
        if count.nil?
          @queue.shift
        else
          @queue.shift(count)
        end
      end

      def add_downloaded(page)
        @downloaded_pages.push page
      end

      def add_error_page(page)
        @error_pages.push page
      end

      def has_work?
        @queue.count > 0 || @downloaded_pages.count > 0
      end

    end
  end
end

Scruber::Queue.add_adapter(:memory, Scruber::QueueAdapters::Memory)