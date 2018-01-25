module Crawley
  module Core
    class Crawler
      def initialize(options={})
        @callbacks_options = {}
        @callbacks = {}
        @queue = Crawley::QueueDriver[::Crawley.configuration.queue_driver].new(::Crawley.configuration.queue_options)
        @fetcher = Crawley::Fetcher[::Crawley.configuration.fetcher_driver].new(::Crawley.configuration.fetcher_options)
      end

      # 
      # Run crawling.
      # 
      # @param block [Proc] crawler body
      def run(&block)
        instance_eval &block
        while @queue.has_work? do
          @fetcher.run @queue
          while page = @queue.shift_for_parsing do
            if @callbacks[page.page_type.to_sym]
              processed_page = process_page(page, page.page_type.to_sym)
              instance_exec page, processed_page, &(@callbacks[page.page_type.to_sym])
            end
          end
        end
      end

      def queue
        @queue
      end

      def fetcher
        @fetcher
      end

      def parser(page_type, options={}, &block)
        register_callback(page_type, options, &block)
      end

      # def run(instance, evaluator)
      #   case block.arity
      #   when 1, -1 then syntax_runner.instance_exec(instance, &block)
      #   when 2 then syntax_runner.instance_exec(instance, evaluator, &block)
      #   else        syntax_runner.instance_exec(&block)
      #   end
      # end
      private

        def register_callback(page_type, options, &block)
          @callbacks_options[page_type.to_sym] = options || {}
          @callbacks[page_type.to_sym] = block
        end

        def process_page(page, page_type)
          page_format = @callbacks_options[page_type].fetch(:page_format){ nil }
          Crawley::Core::PageFormat.process(page, page_format)
        end
    end
  end
end
