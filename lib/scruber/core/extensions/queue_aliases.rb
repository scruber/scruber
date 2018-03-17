module Scruber
  module Core
    module Extensions
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
