module Scruber
  module Core
    # 
    # Crawler class
    # 
    # Main class-runner for scrapers.
    # 
    # @example Simple scraper
    #   Scruber::Core::Crawler.new(:simple) do
    #     get 'http://example.com'
    #     parse :html do |page,html|
    #       puts html.at('title').text
    #     end
    #   end
    # 
    # @author Ivan Goncharov
    #     
    class Crawler
      attr_reader :queue, :fetcher, :scraper_name

      # 
      # Initialize crawler with scraper name and/or with options
      #     
      #   Crawler.new(:sample, fetcher_adapter: :custom)
      #   Crawler.new(:sample)
      #   Crawler.new(fetcher_adapter: :custom)
      # 
      # @param args [Array] if first arg is a Symbol, it will be used as scraper_name, hash will me used as configuration options (see {Scruber::Core::Configuration})
      # 
      # @return [Scruber::Core::Crawler] [description]
      def initialize(*args)
        if args.first.is_a?(Hash)
          scraper_name = nil
          options = args.first
        else
          scraper_name, options = args
          options ||= {}
        end
        @scraper_name = scraper_name.present? ? scraper_name : ENV['SCRUBER_SCRAPER_NAME']
        raise Scruber::ArgumentError.new("Scraper name is empty. Pass it to `Scruber.run :name do` or through ENV['SCRUBER_SCRAPER_NAME']") if @scraper_name.blank?
        @scraper_name = @scraper_name.to_sym
        @callbacks_options = {}
        @callbacks = {}
        @on_page_error_callback = nil
        @on_complete_callbacks = []

        Scruber.configuration.merge_options(options)
        ActiveSupport::Dependencies.autoload_paths = Scruber.configuration.autoload_paths

        @queue = Scruber::Queue.new(scraper_name: @scraper_name)
        @fetcher = Scruber::Fetcher.new
        initialize_progressbar
        load_extenstions
      end

      # 
      # Crawling engine
      # 
      # @param block [Proc] crawler body
      def run(&block)
        instance_eval &block
        while @queue.has_work? do
          @fetcher.run @queue
          show_progress
          while page = @queue.fetch_downloaded do
            if @callbacks[page.page_type.to_sym]
              processed_page = process_page(page, page.page_type.to_sym)
              instance_exec page, processed_page, &(@callbacks[page.page_type.to_sym])
              page.processed! unless page.sent_to_redownload?
            end
          end
          if @on_page_error_callback
            while page = @queue.fetch_error do
              instance_exec page, &(@on_page_error_callback)
            end
          end
        end
        @on_complete_callbacks.sort_by{|c| -c[0] }.each do |(_,callback)|
          instance_exec &(callback)
        end
      end

      # 
      # Register parser
      # 
      # @param page_type [Symbol] type of page
      # @param options [Hash] options for parser
      # @option options [Symbol] :format format of page. Scruber automatically process 
      #                                  page body depends on this format. For example :json or :html
      # @param block [Proc] body of parser
      # 
      # @return [void]
      def parser(page_type, options={}, &block)
        register_callback(page_type, options, &block)
      end

      # 
      # Method missing callback. Scruber allows to register
      # regexp and proc body to process calls
      # 
      # @param method_sym [Symbol] missing method name
      # @param arguments [Array] arguments
      # @param block [Proc] block (if passed)
      # 
      # @return [type] [description]
      def method_missing(method_sym, *arguments, &block)
        Scruber::Core::Crawler._registered_method_missings.each do |(pattern, func)|
          if (scan_results = method_sym.to_s.scan(pattern)).present?
            return instance_exec(method_sym, scan_results, arguments+[block], &(func))
          end
        end
        super
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

        # 
        # Register method missing callback
        # 
        # @param pattern [Regexp] Regexp to match missing name
        # @param block [Proc] Body to process missing method
        # 
        # @return [void]
        def register_method_missing(pattern, &block)
          _registered_method_missings[pattern] = block
        end

        # 
        # Registered method missing callbacks dictionary
        # 
        # @return [Hash] callbacks
        def _registered_method_missings
          @registered_method_missings ||= {}
        end
      end

      # 
      # Register callback which will be executed when
      # downloading and parsing will be completed.
      # For example when you need to write results to file,
      # or to close files.
      # @example Close file descriptors
      #     on_complete -1 do
      #       Scruber::Core::Extensions::CsvOutput.close_all
      #     end
      # 
      # @param priority [Integer] priority of this callback
      # @param block [Proc] body of callback
      # 
      # @return [void]
      def on_complete(priority=1, &block)
        @on_complete_callbacks.push [priority,block]
      end

      # 
      # Register callback which will be executed for
      # error pages, like 404 or 500
      # Attention! You should call one of these methods for page
      # to prevent infinite loop: page.processed!, page.delete, page.redownload!(0)
      # @example Processing error page
      #     on_page_error do |page|
      #       if page.response_body =~ /distil/
      #         page.page.redownload!(0)
      #       elsif page.response_code == /404/
      #         get page.at('a.moved_to').attr('href')
      #         page.processed!
      #       else
      #         page.delete
      #       end
      #     end
      # 
      # @param block [Proc] body of callback
      # 
      # @return [void]
      def on_page_error(&block)
        @on_page_error_callback = block
      end

      private

        # 
        # Register parser
        # 
        # @param page_type [Symbol] type of page
        # @param options [Hash] options for parser
        # @option options [Symbol] :format format of page. Scruber automatically process 
        #                                  page body depends on this format. For example :json or :html
        # @param block [Proc] body of parser
        # 
        # @return [void]
        def register_callback(page_type, options, &block)
          @callbacks_options[page_type.to_sym] = options || {}
          @callbacks[page_type.to_sym] = block
        end

        # 
        # Process page body depends on format of this page
        # For example, if page_format = :html, then
        # it will return Nokogiri::HTML(page.response_body)
        # 
        # @param page [Page] page from queue
        # @param page_type [Symbol] name of parser
        # 
        # @return [Object] depends on page_type it will return different objects
        def process_page(page, page_type)
          page_format = @callbacks_options[page_type].fetch(:format){ nil }
          Scruber::Core::PageFormat.process(page, page_format)
        end

        # 
        # Loads all extensions
        # 
        # @return [void]
        def load_extenstions
          Scruber::Core::Extensions::Base.descendants.each(&:register)
        end

        # 
        # Initialize progressbar, that shows progress in console
        # 
        # @return [void]
        def initialize_progressbar
          unless Scruber.configuration.silent
            @progressbar = PowerBar.new
            @progressbar.settings.tty.finite.template.main = "${<msg>} ${<bar> }\e[0m \e[33;1m${<percent>%} (${<done>/<total>})"
            @progressbar.settings.tty.finite.template.padchar = "\e[30;1m#{@progressbar.settings.tty.finite.template.padchar}"
            @progressbar.settings.tty.finite.template.barchar = "\e[34;1m#{@progressbar.settings.tty.finite.template.barchar}"
            @progressbar.settings.tty.finite.template.exit = "\e[?25h\e[0m"  # clean up after us
            @progressbar.settings.tty.finite.template.close = "\e[?25h\e[0m\n" # clean up after us
            @progressbar.settings.tty.finite.output = Proc.new{ |s|
              $stderr.print s
            }
          end
        end

        # 
        # Out progress to console
        # 
        # @return [void]
        def show_progress
          if @progressbar
            s = queue.size
            @progressbar.show({:msg => @proggress_status, :done => queue.downloaded_count, :total => s}) unless s.zero?
          end
        end
    end

  end
end
