module Scruber
  module Core
    module Extensions
      # 
      # Helper to write csv files
      # @example Writing log and products data
      #   Scruber.run :simple do
      #     csv_file Scruber.root.join('log.csv'), col_sep: ';'
      #     csv_products_file Scruber.root.join('products.csv'), col_sep: ';'
      # 
      #     csv_out [Time.now.to_i, 'sample log record']
      #     csv_product_out ['ID', 'Title']
      #     csv_product_out ['1', 'Soap']
      #   end
      # 
      # @author Ivan Goncharov
      # 
      class CsvOutput < Base
        module CoreMethods
          def csv_file(path, options={})
            file_id = options.fetch(:file_id) { :default }.to_sym
            options.delete(:file_id)
            Scruber::Core::Extensions::CsvOutput.register_csv file_id, path, options
            on_complete -1 do
              Scruber::Core::Extensions::CsvOutput.close_all
            end
          end

          def csv_out(fields)
            Scruber::Core::Extensions::CsvOutput.csv_out :default, fields
          end

          # 
          # Registering method missing callbacks on including
          # to crawling class
          # 
          # @param base [Class] class where module was included
          # 
          # @return [void]
          def self.included(base)
            Scruber::Core::Crawler.register_method_missing /\Acsv_(\w+)_file\Z/ do |meth, scan_results, args|
              file_id = scan_results.first.first.to_sym
              path, options = args
              options = {} if options.nil?
              csv_file path, options.merge({file_id: file_id})
              Scruber::Core::Crawler.class_eval do
                define_method "csv_#{file_id}_out".to_sym do |fields|
                  Scruber::Core::Extensions::CsvOutput.csv_out(file_id, fields)
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
