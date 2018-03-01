module Crawley
  module FetcherAdapters
    class AbstractAdapter
      attr_accessor :options, # all passed options
                    :max_concurrency,
                    :max_retry_times,
                    :retry_delays,
                    :followlocation,
                    :request_timeout

      def initialize(options={})
        @options = options
        @max_concurrency = options.fetch(:max_concurrency) { 1 }
        @max_retry_times = options.fetch(:max_retry_times) { 5 }
        @retry_delays = options.fetch(:retry_delays) { [1,2,2,4,4] }
        @followlocation = options.fetch(:followlocation) { false }
        @request_timeout = options.fetch(:request_timeout) { 15 }
      end

      def run(queue)
        raise NotImplementedError
      end

      def before_request_callback(page)
        page
      end

      def after_request_callback(page)
        if bad_response?(page)
          page.retry_at = determine_retry_at(page)
          page.retry_count += 1
          if page.max_retry_times.nil?
            page.max_retry_times = @max_retry_times
          end
        else
          page.fetched_at = Time.now.to_i
        end
        page
      end

      def headers_for(page)
        if page.fetcher_agent
          headers = page.fetcher_agent.headers
        else
          headers = page.headers
        end
        headers = {} unless headers.is_a?(Hash)
        headers["User-Agent"] = user_agent_for(page)
        cookie = cookie_for(page)
        if cookie
          headers["Cookie"] = cookie
        end
        headers
      end

      def cookie_for(page)
        if page.fetcher_agent
          cookie = page.fetcher_agent.cookie_for(page.url)
          cookie.nil? || cookie.empty? ? nil : cookie
        else
          nil
        end
      end

      def user_agent_for(page)
        if page.user_agent
          page.user_agent
        elsif page.fetcher_agent && page.fetcher_agent.user_agent
          page.fetcher_agent.user_agent
        else
          Crawley::Helpers::UserAgentRotator.next
        end
      end

      def proxy_for(page)
        if page.proxy
          page.proxy
        elsif page.fetcher_agent && page.fetcher_agent.proxy
          page.fetcher_agent.proxy
        else
          Crawley::Helpers::ProxyRotator.next
        end
      end

      def determine_retry_at(page)
        delay = @retry_delays[page.retry_count] || @retry_delays.last
        Time.now.to_i + delay
      end

      def bad_response?(page)
        case page.response_code
        when 0
          true
        when 1
          true
        when 100..199
          true
        when 200
          false
        when 201..299
          false
        when 300..399
          @options.fetch(:followlocation) { false }
        when 404
          false
        when 407
          raise "RejectedByProxyError"
        when 400..499
          true
        when 500..599
          true
        else
          true
        end
      end

    end
  end
end
