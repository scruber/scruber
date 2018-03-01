module Crawley
  module Core
    module Extensions
      class CsvOutput < Base
        module CoreMethods
          def csv_file(path, options={})
            file_id = options.fetch(:file_id) { :default }.to_sym
            options.delete(:file_id)
            Crawley::Core::Extensions::CsvOutput.register_csv file_id, path, options
            on_complete_callback :close_csv_files do
              Crawley::Core::Extensions::CsvOutput.close_all
            end
          end

          def csv_out(fields)
            Crawley::Core::Extensions::CsvOutput.csv_out :default, fields
          end

          def self.included(base)
            Crawley::Core::Crawler.register_method_missing /\Acsv_(\w+)_file\Z/ do |meth, args|
              file_id = meth.to_s.scan(/\Acsv_(\w+)_file\Z/).first.first.to_sym
              path, options = args
              options = {} if options.nil?
              csv_file path, options.merge({file_id: file_id})
              Crawley::Core::Crawler.class_eval do
                define_method "csv_#{file_id}_out".to_sym do |fields|
                  Crawley::Core::Extensions::CsvOutput.csv_out(file_id, fields)
                end
              end
            end
          end
        end

        class << self
          def csv_out(file_id, fields)
            if _registered_files.keys.include?(file_id.to_sym)
              _registered_files[file_id.to_sym] << fields
            else
              raise ArgumentError, "file #{file_id.inspect} not registered"
            end
          end

          def register_csv(file_id, path, options)
            mode = options.fetch(:mode){ 'wb' }
            options.delete(:mode)
            _registered_files[file_id] = CSV.open(path, mode, options)
          end

          def _registered_files
            @registered_files ||= {}
          end

          def close_all
            _registered_files.each{ |_,f| f.close }
            @registered_files = {}
          end
        end

      end
    end
  end
end
