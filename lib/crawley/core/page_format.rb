module Crawley
  module Core
    module PageFormat
      class << self
        def process(page, page_format)
          if page_format.nil?
            nil
          elsif _registered_formats.keys.include?(page_format.to_sym)
            _registered_formats[page_format.to_sym].process(page)
          else
            raise "Unsupported format"
          end
        end

        def add(label, claz)
          unless claz.respond_to?(:process)
            raise NoMethodError, "process is not declared in the #{label.inspect}"
          end

          _registered_formats[label] = claz
        end

        def [](label)
          _registered_formats[label]
        end

        def _registered_formats
          @registered_formats ||= {}
        end
      end
    end
  end
end