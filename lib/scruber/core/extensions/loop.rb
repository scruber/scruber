module Scruber
  module Core
    module Extensions
      # 
      # Helper for reading dictionaries.
      # @example Adding dictionary and reading it
      #     Scruber.run :sample do
      #       add_dictionary :zip_codes_usa, Scruber.root.join('dict', 'zip_codes_usa.csv'), :csv
      #       seed do
      #         loop :zip_codes_usa, state: 'NY' do |row|
      #           get 'https://example.com/by_zip/'+row['zip'].to_s
      #         end
      #       end
      #     end
      # 
      # @author Ivan Goncharov
      # 
      class Loop < Base
        module CoreMethods
          # 
          # Iterate records from dictionary
          # 
          # @param dictionary [Symbol] name of dictionary
          # @param options [Hash] search conditions
          # @param block [Proc] body, yields row of dictionary
          # 
          # @return [void]
          def loop(dictionary, options={}, &block)
            Scruber::Core::Extensions::Loop.loop dictionary, options do |*args|
              instance_exec *args, &block
            end
          end

          # 
          # Registering dictionary in system
          # 
          # @param name [Symbol] name of dictionary
          # @param file_path [String] path to file
          # @param file_type [Symbol] type of file, :xml, :csv, etc..
          # 
          # @return [void]
          def add_dictionary(name, file_path, file_type)
            Scruber::Core::Extensions::Loop.add_dictionary(name, file_path, file_type)
          end
        end

        class << self
          def loop(dictionary, options={})
            if _registered_dictionaries.keys.include?(dictionary.to_sym)
              Scruber::Helpers::DictionaryReader.read(_registered_dictionaries[dictionary.to_sym][:file_path], _registered_dictionaries[dictionary.to_sym][:file_type], options) do |obj|
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
