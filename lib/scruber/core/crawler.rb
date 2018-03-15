module Scruber
  module Core
    class Crawler
      attr_reader :queue, :fetcher, :scraper_name

      def initialize(scraper_name, options={})
        @scraper_name = scraper_name
        Scruber.configuration.merge_options(options)
        @callbacks_options = {}
        @callbacks = {}
        @on_complete_callbacks = {}
        @queue = Scruber::Queue.new(scraper_name: scraper_name)
        @fetcher = Scruber::Fetcher.new
        load_extenstions
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
        Scruber::Core::Crawler._registered_method_missings.find do |(pattern, func)|
          if (scan_results = method_sym.to_s.scan(pattern)).present?
            instance_exec method_sym, scan_results, arguments, &(func)
            true
          else
            false
          end
        end || super
      end

      def respond_to?(method_sym, include_private = false)
        !Scruber::Core::Crawler._registered_method_missings.find do |(pattern, block)|
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
          Scruber::Core::PageFormat.process(page, page_format)
        end

        def load_extenstions
          Scruber::Core::Extensions::Base.descendants.each(&:register)
        end
    end
  end
end
