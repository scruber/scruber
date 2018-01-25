require 'typhoeus'
module Crawley
  module Fetcher
    class TyphoeusFetcher
      # Available options for this fetcher
      attr_accessor :options, # all passed options
                    :max_concurrency, # max concurrency for Hydra
                    :proxy, # Typhoeus proxy url. example: 'http://localhost:5000'
                    :proxyuserpwd, # Typhoeus proxy password. example: 'user:password'
                    :request_timeout # Request timeout for Typhoeus

      def initialize(options={})
        @options = options
        @max_concurrency = options.fetch(:max_concurrency) { 1 }
        @proxy = options.fetch(:proxy) { nil }
        @proxyuserpwd = options.fetch(:proxyuserpwd) { nil }
        @request_timeout = options.fetch(:request_timeout) { 15 }
      end

      def run(queue)
        (1..@max_concurrency).each do
          page = queue.shift_for_fetching
          request = build_request(page)

          hydra.queue(request)
        end
        if hydra.queued_requests.count > 0
          hydra.run
        else
          sleep 1
        end
      end

      def build_request(page)
        request_options = {
          method: page[:method],
          body: page[:body],
          # params: page[:params],
          headers: page[:headers],
          accept_encoding: 'gzip',
          forbid_reuse: true, #false,
          followlocation: true,
          ssl_verifypeer: false,
          ssl_verifyhost: 0,
          timeout: @request_timeout
        }
        page.fetching_at = Time.now.to_i
        
        request_options.merge!({proxy: @proxy}) if @proxy
        request_options.merge!({proxyuserpwd: @proxyuserpwd}) if @proxyuserpwd
        
        if page.user_agent
          request_options[:headers] = {"User-Agent" => page.user_agent, 'Accept-Charset' => 'utf-8'}
        else
          request_options[:headers] = {"User-Agent" => Crawley::Helpers::UserAgentRotator.random, 'Accept-Charset' => 'utf-8'}
        end

        request = Typhoeus::Request.new(page[:url], request_options)

        request.on_complete do |response|
          on_complete_callback(page, response)
        end

        request
      end

      def hydra
        @hydra ||= Typhoeus::Hydra.new(max_concurrency: @max_concurrency)
      end

      def on_complete_callback(page, response)
        page.response_code = response.code
        page.response_body = response.body
        page.response_headers = response.response_headers
        page.response_total_time = response.total_time
        
        if response.timed_out?
          page[:response_code] = 1
        end

        retry_later   = determine_retry(response.code)
        if retry_later
          if page.retries_left > 0
            page.retries_left -= 1
          end
          # page.fetching_at = determine_retry_at(page.retries_left)
          page.save
        else
          page.fetched_at = Time.now.to_i
          page.save
        end
      end

      def determine_retry(response_code)
        case response_code
        when 0 # Typheous 0 code means server is unreachable
          true
        when 1 # Timed out
          true
        when 100..199
          true
        when 200
          false
        when 201..299
          false
        when 300..399
          false
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

Crawley::Fetcher.add(:typhoeus_fetcher, Crawley::Fetcher::TyphoeusFetcher)