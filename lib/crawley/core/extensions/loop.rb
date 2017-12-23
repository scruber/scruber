module Crawley
  module Core
    module Extensions
      class Loop < Base
        module CoreMethods
          def loop(dictionary, options={}, &block)
            Crawley::Core::Extensions::Loop.loop dictionary, options do |*args|
              instance_exec *args, &block
            end
          end
        end

        class << self
          def loop(dictionary, options={})
            if _registered_dictionaries.keys.include?(dictionary.to_sym)
              Crawley::Helpers::DictionaryReader.read(_registered_dictionaries[dictionary.to_sym][:file_path], _registered_dictionaries[dictionary.to_sym][:file_type], options) do |obj|
                yield obj
              end
            else
              raise ArgumentError, "dictionary not registered, available dictionaries #{_registered_dictionaries.keys.inspect}"
            end
          end

          def add_dictionary(name, file_path, file_type)
            _registered_dictionaries[name.to_sym] = {
              file_path: file_path,
              file_type: file_type
            }
          end

          def _registered_dictionaries
            @registered_dictionaries ||= {}
          end
        end

      end
    end
  end
end
