module Scruber
  module Core
    module Extensions
      # 
      # DSL for registering parsers.
      # @example Sample of DSL
      #   Scruber.run :sample do
      #     get 'https://example.com'
      #     get_product 'https://example.com/product1.html'
      #   
      #     # Parsing https://example.com
      #     parse :html do |page,doc|
      #       log doc.at('title').text
      #     end
      #   
      #     # Parsing https://example.com/product1.html
      #     parse_product :html do |page,doc|
      #       log doc.at('title').text
      #     end
      #     # Alias to
      #     # parser :product, format: :html do |page,doc|
      #     #   log doc.at('title').text
      #     # end
      #   end
      # 
      # @author Ivan Gocharov
      # 
      class ParserAliases < Base
        module CoreMethods
          def parse(*args, &block)
            page_format = args.shift
            parser('seed', {format: page_format}, &block)
          end

          def self.included(base)
            Scruber::Core::Crawler.register_method_missing /\Aparse_(\w+)\Z/ do |meth, scan_results, args|
              page_type = scan_results.first.first
              page_format = args.first.is_a?(Symbol) ? args.shift : nil
              block = args.shift
              parser(page_type, {format: page_format}, &block)
            end
          end
        end

      end
    end
  end
end
