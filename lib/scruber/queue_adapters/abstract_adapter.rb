module Scruber
  module QueueAdapters
    # 
    # Abstract Queue Adapter
    # 
    # @abstract
    # @author Ivan Goncharov
    # 
    class AbstractAdapter
      # 
      # Queue page wrapper
      # 
      # @author Ivan Goncharov
      # 
      # @attr [String] url URL of page
      # @attr [String] method Request method, post, get, head
      # @attr [String] user_agent Fixed User-Agent for requesting this page
      # @attr [Hash] headers Headers for requesting this page
      # @attr [Object] fetcher_agent_id ID of FetcherAgent, assigned to this page
      # @attr [Object] proxy_id ID of proxy, assigned to this page
      # @attr [String] response_body Response body
      # @attr [Integer] response_code Response code
      # @attr [Hash] response_headers Response headers
      # @attr [Float] response_total_time Response total time
      # @attr [Integer] retry_at Minimal timestamp of next retry
      # @attr [Integer] fetched_at Download completion timestamp
      # @attr [Integer] retry_count Number of download attempts
      # @attr [Integer] max_retry_times Max number of download attempts
      # @attr [Integer] enqueued_at Timestamp added to the queue
      # @attr [String] page_type Page type
      # @attr [Scruber::QueueAdapters::AbstractAdapter::Page] queue Queue object
      # @attr [Integer] priority Priority of page in queue for fetcher
      # @attr [Integer] processed_at Processed by parser timestamp
      # @attr [Hash] options All options
      class Page
        attr_accessor :url,
                      :method,
                      :user_agent,
                      :post_body,
                      :headers,
                      :fetcher_agent_id,
                      :proxy_id,
                      :response_body,
                      :response_code,
                      :response_headers,
                      :response_total_time,
                      :retry_at,
                      :fetched_at,
                      :retry_count,
                      :max_retry_times,
                      :enqueued_at,
                      :page_type,
                      :queue,
                      :priority,
                      :processed_at,
                      :options

        def initialize(queue, url, options={})
          @queue = queue
          @url = url

          options = options.with_indifferent_access
          @method = options.fetch(:method) { :get }
          @user_agent = options.fetch(:user_agent) { nil }
          @post_body = options.fetch(:post_body) { nil }
          @headers = options.fetch(:headers) { {} }
          @fetcher_agent_id = options.fetch(:fetcher_agent_id) { nil }
          @proxy_id = options.fetch(:proxy_id) { nil }
          @response_body = options.fetch(:response_body) { nil }
          @response_code = options.fetch(:response_code) { nil }
          @response_headers = options.fetch(:response_headers) { {} }
          @response_total_time = options.fetch(:response_total_time) { nil }
          @retry_at = options.fetch(:retry_at) { 0 }
          @fetched_at = options.fetch(:fetched_at) { 0 }
          @retry_count = options.fetch(:retry_count) { 0 }
          @max_retry_times = options.fetch(:max_retry_times) { nil }
          @enqueued_at = options.fetch(:enqueued_at) { 0 }
          @page_type = options.fetch(:page_type) { :seed }
          # @queue = options.fetch(:queue) { 'default' }
          @priority = options.fetch(:priority) { 0 }
          @processed_at = options.fetch(:processed_at) { 0 }
          @options = options

          @_fetcher_agent = false
          @_proxy = false
          @_redownload = false
        end

        # 
        # Returns assigned to this page FetcherAgent
        # 
        # @return [Scruber::Helpers::FetcherAgent] Agent object
        def fetcher_agent
          if @_fetcher_agent == false
            @_fetcher_agent = (@fetcher_agent_id ? Scruber::Helpers::FetcherAgent.find(@fetcher_agent_id) : nil)
          else
            @_fetcher_agent
          end
        end

        # 
        # Returns assigned to this page proxy
        # 
        # @return [Proxy] proxy object
        def proxy
          if @_proxy == false
            @_proxy = (@proxy_id ? Scruber::Helpers::ProxyRotator.find(@proxy_id) : nil)
          else
            @_proxy
          end
        end

        # 
        # Returns cookies from response headers
        # 
        # @return [Array] array of cookies
        def response_cookies
          cookies = self.response_headers['Set-Cookie']
          if cookies.blank?
            []
          else
            if cookies.is_a?(Array)
              cookies
            else
              [cookies]
            end
          end
        end

        def save
          raise NotImplementedError
        end

        def [](k)
          instance_variable_get("@#{k.to_s}")
        end

        # 
        # Delete page from queue
        # 
        # @return [void]
        def delete
          raise NotImplementedError
        end

        # 
        # Mark page as processed by parser and save it
        # 
        # @return [void]
        def processed!
          @processed_at = Time.now.to_i
          @_redownload = false
          save
        end

        # 
        # Mark page as pending and return to queue
        # 
        # @return [void]
        def redownload!
          @_redownload = true

          @processed_at = nil
          @retry_count += 1
          @fetched_at = 0
          @response_body = nil
          save
        end

        # 
        # Marked as page for redownloading
        # 
        # @return [Boolean] true if need to redownload
        def sent_to_redownload?
          @_redownload
        end
      end

      def initialize(options={})
        @options = options
      end

      # 
      # Add page to queue
      # @param url [String] URL of page
      # @param options [Hash] Other options, see {Scruber::QueueAdapters::AbstractAdapter::Page}
      # 
      # @return [void]
      def add(url, options={})
        raise NotImplementedError
      end

      # 
      # Size of queue
      # 
      # @return [Integer] count of pages in queue
      def size
        raise NotImplementedError
      end

      # 
      # Fetch pending page for fetching
      # @param count=nil [Integer] count of pages to fetch
      # 
      # @return [Scruber::QueueAdapters::AbstractAdapter::Page|Array<Scruber::QueueAdapters::AbstractAdapter::Page>] page of count = nil, or array of pages of count > 0
      def fetch_pending(count=nil)
        raise NotImplementedError
      end

      # 
      # Fetch downloaded and not processed pages for feching
      # @param count=nil [Integer] count of pages to fetch
      # 
      # @return [Scruber::QueueAdapters::AbstractAdapter::Page|Array<Scruber::QueueAdapters::AbstractAdapter::Page>] page of count = nil, or array of pages of count > 0
      def fetch_downloaded(count=nil)
        raise NotImplementedError
      end

      # 
      # Count of downloaded pages
      # Using to show downloading progress.
      # 
      # @return [Integer] count of downloaded pages
      def downloaded_count
        raise NotImplementedError
      end

      # 
      # Check if queue was initialized.
      # Using for `seed` method. If queue was initialized,
      # then no need to run seed block.
      # 
      # @return [Boolean] true if queue already was initialized
      def initialized?
        raise NotImplementedError
      end

      # 
      # Used by Core. It checks for pages that are
      # not downloaded or not parsed yet.
      # 
      # @return [Boolean] true if queue still has work for scraper
      def has_work?
        raise NotImplementedError
      end
    end
  end
end