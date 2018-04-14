require 'typhoeus'
module Scruber
  module FetcherAdapters
    class TyphoeusFetcher < AbstractAdapter
      attr_accessor :ssl_verifypeer,
                    :ssl_verifyhost

      def initialize(options={})
        super(options)
        @ssl_verifypeer = options.fetch(:ssl_verifypeer) { false }
        @ssl_verifyhost = options.fetch(:ssl_verifyhost) { 0 }
        @max_requests = options.fetch(:max_requests) { @max_concurrency * 10 }
      end

      def run(queue)
        queue.fetch_pending(@max_requests).each do |page|
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
        page = before_request_callback(page)
        request_options = {
          method: page[:method],
          body: page[:body],
          # params: page[:params],
          headers: headers_for(page),
          accept_encoding: 'gzip',
          forbid_reuse: true,
          followlocation: page.options.fetch(:followlocation){ @followlocation },
          ssl_verifypeer: page.options.fetch(:ssl_verifypeer){ @ssl_verifypeer },
          ssl_verifyhost: page.options.fetch(:ssl_verifyhost){ @ssl_verifyhost },
          timeout: @request_timeout
        }
        
        proxy = proxy_for(page)
        request_options.merge!({proxy: proxy.http? ? proxy.address :  "socks://#{proxy.address}"}) if proxy
        request_options.merge!({proxyuserpwd: proxy.proxyuserpwd}) if proxy && proxy.proxyuserpwd.present?

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
          page.response_code = 1
        end

        page = after_request_callback(page)
        page.save
      end

    end
  end
end

Scruber::Fetcher.add_adapter(:typhoeus_fetcher, Scruber::FetcherAdapters::TyphoeusFetcher)