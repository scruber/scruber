module Crawley
  module QueueAdapters
    class AbstractAdapter
      
      class Page
        attr_accessor :url,
                      :method,
                      :user_agent,
                      :post_body,
                      :headers,
                      :response_body,
                      :response_code,
                      :response_headers,
                      :response_total_time,
                      :fetching_at,
                      :fetched_at,
                      :retries_left,
                      :enqueued_at,
                      :page_type,
                      :queue,
                      :priority,
                      :processed_at,
                      :options

        def initialize(queue, url, options={})
          @queue = queue
          @url = url
          @method = options.fetch(:method) { :get }
          @user_agent = options.fetch(:user_agent) { nil }
          @post_body = options.fetch(:post_body) { nil }
          @headers = options.fetch(:headers) { {} }
          @response_body = options.fetch(:response_body) { nil }
          @response_code = options.fetch(:response_code) { nil }
          @response_headers = options.fetch(:response_headers) { {} }
          @response_total_time = options.fetch(:response_total_time) { nil }
          @fetching_at = options.fetch(:fetching_at) { 0 }
          @fetched_at = options.fetch(:fetched_at) { 0 }
          @retries_left = options.fetch(:retries_left) { 5 }
          @enqueued_at = options.fetch(:enqueued_at) { 0 }
          @page_type = options.fetch(:page_type) { :seed }
          # @queue = options.fetch(:queue) { 'default' }
          @priority = options.fetch(:priority) { 0 }
          @processed_at = options.fetch(:processed_at) { 0 }
          @options = options
        end

        def response_cookies
          cookies = self.response_headers['Set-Cookie']
          if cookies.nil? || cookies.empty?
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
          if self.fetched_at > 0
            @queue.push_for_parsing self
          elsif self.retries_left.zero?
            @queue.puts_error_page self
          else
            @queue.push self
          end
        end

        def [](k)
          instance_variable_get("@#{k.to_s}")
        end

      end

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