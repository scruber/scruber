module Crawley
  module Core
    class Crawler
      attr_reader :queue, :fetcher

      def initialize(options={})
        Crawley.configuration.merge_options(options)
        @callbacks_options = {}
        @callbacks = {}
        @on_complete_callbacks = {}
        @queue = Crawley::Queue.new
        @fetcher = Crawley::Fetcher.new
      end

      # 
      # Run crawling.
      # 
      # @param block [Proc] crawler body
      def run(&block)
        instance_eval &block
        while @queue.has_work? do
          @fetcher.run @queue
          while page = @queue.fetch_downloaded do
            if @callbacks[page.page_type.to_sym]
              processed_page = process_page(page, page.page_type.to_sym)
              instance_exec page, processed_page, &(@callbacks[page.page_type.to_sym])
            end
          end
        end
        @on_complete_callbacks.each do |_,callback|
          instance_exec &(callback)
        end
      end

      def parser(page_type, options={}, &block)
        register_callback(page_type, options, &block)
      end

      def method_missing(method_sym, *arguments, &block)
        Crawley::Core::Crawler._registered_method_missings.find do |(pattern, func)|
          if method_sym.to_s =~ pattern
            instance_exec method_sym, arguments, &(func)
            true
          else
            false
          end
        end || super
      end

      def respond_to?(method_sym, include_private = false)
        !Crawley::Core::Crawler._registered_method_missings.find do |(pattern, block)|
          if method_sym.to_s =~ pattern
            true
          else
            false
          end
        end.nil? || super(method_sym, include_private)
      end

      class << self
        def register_method_missing(pattern, &block)
          _registered_method_missings[pattern] = block
        end

        def _registered_method_missings
          @registered_method_missings ||= {}
        end
      end

      private

        def register_callback(page_type, options, &block)
          @callbacks_options[page_type.to_sym] = options || {}
          @callbacks[page_type.to_sym] = block
        end

        def on_complete_callback(name, &block)
          @on_complete_callbacks[name] = block
        end

        def process_page(page, page_type)
          page_format = @callbacks_options[page_type].fetch(:page_format){ nil }
          Crawley::Core::PageFormat.process(page, page_format)
        end
    end
  end
end
