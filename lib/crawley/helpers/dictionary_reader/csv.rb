require 'csv'
module Crawley
  module Helpers
    module DictionaryReader
      class Csv
        def initialize(file_path)
          @file_path = file_path
        end

        def read(options={})
          col_sep = options.delete(:col_sep) || ';'

          CSV.foreach(@file_path, col_sep: col_sep, headers: true, encoding: 'utf-8') do |csv_row|
            if options.empty?
              yield csv_row
            else
              if options.all?{|(k,v)| csv_row[k.to_s] == v }
                yield csv_row
              end
            end
          end
        end
      end
    end
  end
end

Crawley::Helpers::DictionaryReader.add(:csv, Crawley::Helpers::DictionaryReader::Csv)