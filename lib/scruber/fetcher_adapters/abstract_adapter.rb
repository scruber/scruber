require 'charlock_holmes'

module Scruber
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
          if page.max_retry_times && page.retry_count >= page.max_retry_times.to_i
            page.retry_at = 1.year.from_now.to_i
          end
        else
          # Monkey patch to prevent redownloading of 404 pages
          # and processing 404 pages by regular parsers
          if page.response_code == 404
            page.retry_count = 1 if page.retry_count.nil? || page.retry_count.zero?
            page.max_retry_times = page.retry_count
          else
            page.fetched_at = Time.now.to_i
          end
        end
        if page.response_headers
          page.response_headers = page.response_headers.inject({}) {|acc, (k,v)| acc[k.gsub('.', '_')] = convert_to_utf8(v); acc }
        end
        page.response_body = convert_to_utf8(page.response_body)
        page
      end

      def convert_to_utf8(text)
        unless text.to_s.empty?
          detection = CharlockHolmes::EncodingDetector.detect(text)
          if detection && detection[:encoding].present?
            text = CharlockHolmes::Converter.convert(text, detection[:encoding], 'UTF-8') rescue text
          end
        end

        text
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
          cookie.blank? ? nil : cookie
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
          Scruber::Helpers::UserAgentRotator.next
        end
      end

      def proxy_for(page)
        if page.proxy
          page.proxy
        elsif page.fetcher_agent && page.fetcher_agent.proxy
          page.fetcher_agent.proxy
        else
          Scruber::Helpers::ProxyRotator.next
        end
      end

      def determine_retry_at(page)
        delay = @retry_delays[page.retry_count] || @retry_delays.last
        Time.now.to_i + delay
      end

      def bad_response?(page)
        case page.response_code
        when 0..1
          true
        when 200..299
          false
        when 300..399
          @options.fetch(:followlocation) { false }
        when 404
          false
        when 407
          raise "RejectedByProxy"
        else
          true
        end
      end

    end
  end
end
