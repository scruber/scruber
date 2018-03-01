module Crawley
  module Helpers
    module FetcherAgentAdapters
      class AbstractAdapter
        attr_accessor :id, :user_agent, :proxy_id, :headers, :cookie_jar, :updated_at, :created_at, :disable_proxy
        attr_reader :jar

        def initialize(options={})
          @id = options.fetch(:id) { nil }
          @user_agent = options.fetch(:user_agent) { nil }
          @proxy_id = options.fetch(:proxy_id) { nil }
          @headers = options.fetch(:headers) { {} }
          @cookie_jar = options.fetch(:cookie_jar) { {} }
          @disable_proxy = options.fetch(:disable_proxy) { false }
          @updated_at = options.fetch(:updated_at) { Time.now }
          @created_at = options.fetch(:created_at) { Time.now }
          @jar = HTTP::CookieJar.new
          if @cookie_jar.is_a?(String)
            @jar.load(StringIO.new(@cookie_jar))
          end
          @_proxy = false
        end

        def proxy
          if @_proxy == false
            @_proxy = (@proxy_id ? Crawley::Helpers::ProxyRotator.find(@proxy_id) : nil)
          else
            @_proxy
          end
        end

        def parse_cookies_from_page!(page)
          cookies = page.response_cookies
          cookies.each do |cookie|
            @jar.parse(cookie, URI(page.url))
          end
        end

        def serialize_cookies
          io = StringIO.new
          @jar.save(io)
          @cookie_jar = io.string
        end

        def cookie_for(uri_or_url)
          if uri_or_url.is_a?(String)
            uri_or_url = URI(uri_or_url)
          end
          HTTP::Cookie.cookie_value(@jar.cookies(uri_or_url))
        end

        def save
          raise NotImplementedError
        end

        def delete
          raise NotImplementedError
        end

        class << self
          def find(id)
            raise NotImplementedError
          end
        end

      end
    end
  end
end
