module Scruber
  module QueueAdapters
    class AbstractAdapter
      
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

        def fetcher_agent
          if @_fetcher_agent == false
            @_fetcher_agent = (@fetcher_agent_id ? Scruber::Helpers::FetcherAgent.find(@fetcher_agent_id) : nil)
          else
            @_fetcher_agent
          end
        end

        def proxy
          if @_proxy == false
            @_proxy = (@proxy_id ? Scruber::Helpers::ProxyRotator.find(@proxy_id) : nil)
          else
            @_proxy
          end
        end

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

        def delete
          raise NotImplementedError
        end

        def processed!
          @processed_at = Time.now.to_i
          @_redownload = false
          save
        end

        def redownload!
          @_redownload = true

          @processed_at = nil
          @retry_count += 1
          @fetched_at = 0
          @response_body = nil
          save
        end

        def sent_to_redownload?
          @_redownload
        end
      end

      def initialize(options={})
        @options = options
      end

      def add(url, options={})
        raise NotImplementedError
      end

      def size
        raise NotImplementedError
      end

      def fetch_pending(count=nil)
        raise NotImplementedError
      end

      def fetch_downloaded(count=nil)
        raise NotImplementedError
      end

      def initialized?
        raise NotImplementedError
      end
    end
  end
end