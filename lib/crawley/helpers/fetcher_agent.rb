module Crawley
  module Helpers
    class FetcherAgent
      attr_accessor :id, :user_agent, :proxy_id, :headers, :cookie, :updated_at, :created_at, :use_proxy

      def initialize(options={})
        @id = options.fetch(:id) { nil }
        @user_agent = options.fetch(:user_agent) { nil }
        @proxy_id = options.fetch(:proxy_id) { nil }
        @headers = options.fetch(:headers) { {} }
        @cookie = options.fetch(:cookie) { {} }
        @use_proxy = options.fetch(:use_proxy) { nil }
        @updated_at = options.fetch(:updated_at) { Time.now }
        @created_at = options.fetch(:created_at) { Time.now }
      end

    end
  end
end
