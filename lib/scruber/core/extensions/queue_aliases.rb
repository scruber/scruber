module Scruber
  module Core
    module Extensions
      # 
      # DSL for adding pages to queue
      # @example Sample of DSL
      #   Scruber.run :sample do
      #     get_product 'https://example.com/product1.html'
      #     # Alias to
      #     # queue.add 'https://example.com/product1.html', page_type: :product
      # 
      #     post_subscribe 'https://example.com/subscribe', body: { email: 'sample@example.com' }
      #     # Alias to
      #     # queue.add 'https://example.com/product1.html', method: :post, page_type: :subscribe, body: { email: 'sample@example.com' }
      #   end
      # 
      # @author Ivan Gocharov
      # 
      class QueueAliases < Base
        module CoreMethods
          %w(get post head).each do |meth|
            define_method meth.to_sym do |url, options={}|
              queue.add url, options.merge({method: meth.to_sym})
            end
          end

          def self.included(base)
            Scruber::Core::Crawler.register_method_missing /\A(get|post|head)_(\w+)\Z/ do |m, scan_results, args|
              meth, page_type = scan_results.first
              url, options = args
              options = {} if options.nil?
              Scruber::Core::Crawler.class_eval do
                define_method "#{meth}_#{page_type}".to_sym do |url, options={}|
                  queue.add url, options.merge({method: meth.to_sym, page_type: page_type})
                end
              end
              queue.add url, options.merge({method: meth.to_sym, page_type: page_type})
            end
          end
        end

      end
    end
  end
end
