module Crawley
  module Helpers
    module DictionaryReader
      class << self 
        def read(file_path, file_type, options)
          if _registered_types.keys.include?(file_type.to_sym)
            _registered_types[file_type.to_sym].new(file_path).read(options) do |obj|
              yield obj
            end
          else
            raise "Unsupported type, supported types #{_registered_types.keys}"
          end
        end

        def add(label, claz)
          unless claz.instance_methods.include?(:read)
            raise NoMethodError, "read is not declared in the #{claz.inspect}"
          end

          _registered_types[label] = claz
        end

        def [](label)
          _registered_types[label]
        end

        def _registered_types
          @registered_types ||= {}
        end
      end
    end
  end
end