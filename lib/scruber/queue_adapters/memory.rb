module Scruber
  module QueueAdapters
    # 
    # Memory Queue Adapter
    # 
    # Simple queue adapted which stores pages in memory.
    # Nice solution for small scrapes.
    # Easy to use. No need to setup any database, but
    # no ability to reparse pages if something went wrong.
    # 
    # @author Ivan Goncharov
    # 
    class Memory < AbstractAdapter
      attr_reader :error_pages

      # 
      # [class description]
      # 
      # @author [revis0r]
      # 
      # @attr (see Scruber::QueueAdapters::AbstractAdapter::Page)
      # 
      class Page < Scruber::QueueAdapters::AbstractAdapter::Page

        # 
        # Save page
        # 
        # Depends on page attributes it push page
        # to pending, downloaded or error queue.
        # 
        # @return [void]
        def save
          if self.processed_at.to_i > 0
            @queue.add_processed_page self
          elsif self.fetched_at > 0
            @queue.add_downloaded self
          elsif self.max_retry_times && self.retry_count >= self.max_retry_times.to_i
            @queue.add_error_page self
          else
            @queue.add self
          end
        end

        # 
        # Delete page from all queues
        # 
        # @return [void]
        def delete
          @queue.delete self
        end
      end

      def initialize(options={})
        super(options)
        @processed_ids = []
        @queue = []
        @downloaded_pages = []
        @error_pages = []
      end

      # 
      # Add page to queue
      # @param url [String] URL of page
      # @param options [Hash] Other options, see {Scruber::QueueAdapters::AbstractAdapter::Page}
      # 
      # @return [void]
      def add(url_or_page, options={})
        unless url_or_page.is_a?(Page)
          url_or_page = Page.new(self, options.merge(url: url_or_page))
        end
        @queue.push(url_or_page) unless @processed_ids.include?(url_or_page.id) || find(url_or_page.id)
      end
      alias_method :push, :add

      # 
      # Search page by id
      # @param id [Object] id of page
      # 
      # @return [Page] page
      def find(id)
        [@queue, @downloaded_pages, @error_pages].each do |q|
          q.each do |i|
            return i if i.id == id
          end
        end
        nil
      end

      # 
      # Size of queue
      # 
      # @return [Integer] count of pages in queue
      def size
        @queue.count
      end

      # 
      # Count of downloaded pages
      # Using to show downloading progress.
      # 
      # @return [Integer] count of downloaded pages
      def downloaded_count
        @downloaded_pages.count
      end

      # 
      # Fetch downloaded and not processed pages for feching
      # @param count=nil [Integer] count of pages to fetch
      # 
      # @return [Scruber::QueueAdapters::AbstractAdapter::Page|Array<Scruber::QueueAdapters::AbstractAdapter::Page>] page of count = nil, or array of pages of count > 0
      def fetch_downloaded(count=nil)
        if count.nil?
          @downloaded_pages.shift
        else
          @downloaded_pages.shift(count)
        end
      end

      # 
      # Fetch error page
      # @param count=nil [Integer] count of pages to fetch
      # 
      # @return [Scruber::QueueAdapters::AbstractAdapter::Page|Array<Scruber::QueueAdapters::AbstractAdapter::Page>] page of count = nil, or array of pages of count > 0
      def fetch_error(count=nil)
        if count.nil?
          @error_pages.shift
        else
          @error_pages.shift(count)
        end
      end

      # 
      # Fetch pending page for fetching
      # @param count=nil [Integer] count of pages to fetch
      # 
      # @return [Scruber::QueueAdapters::AbstractAdapter::Page|Array<Scruber::QueueAdapters::AbstractAdapter::Page>] page of count = nil, or array of pages of count > 0
      def fetch_pending(count=nil)
        if count.nil?
          @queue.shift
        else
          @queue.shift(count)
        end
      end

      # 
      # Internal method to add page to downloaded queue
      # 
      # @param page [Scruber::QueueAdapters::Memory::Page] page
      # 
      # @return [void]
      def add_downloaded(page)
        @downloaded_pages.push page
      end

      # 
      # Internal method to add page to error queue
      # 
      # @param page [Scruber::QueueAdapters::Memory::Page] page
      # 
      # @return [void]
      def add_error_page(page)
        @error_pages.push page
      end

      # 
      # Saving processed page id to prevent
      # adding identical pages to queue
      # 
      # @param page [Page] page
      # 
      # @return [void]
      def add_processed_page(page)
        @processed_ids.push page.id
      end

      # 
      # Used by Core. It checks for pages that are
      # not downloaded or not parsed yet.
      # 
      # @return [Boolean] true if queue still has work for scraper
      def has_work?
        @queue.count > 0 || @downloaded_pages.count > 0
      end

      # 
      # Delete page from all internal queues
      # 
      # @param page [Scruber::QueueAdapters::Memory::Page] page
      # 
      # @return [void]
      def delete(page)
        @queue -= [page]
        @downloaded_pages -= [page]
        @error_pages -= [page]
      end

      # 
      # Check if queue was initialized.
      # Using for `seed` method. If queue was initialized,
      # then no need to run seed block.
      # 
      # @return [Boolean] true if queue already was initialized
      def initialized?
        @queue.present? || @downloaded_pages.present? || @error_pages.present?
      end

    end
  end
end

Scruber::Queue.add_adapter(:memory, Scruber::QueueAdapters::Memory)