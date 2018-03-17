module Scruber
  module Core
    module Extensions
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
