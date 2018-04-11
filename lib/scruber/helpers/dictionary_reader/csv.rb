module Scruber
  module Helpers
    module DictionaryReader
      class Csv
        def initialize(file_path)
          @file_path = file_path
        end

        def read(options={})
          col_sep = options.delete(:col_sep) || ','

          CSV.foreach(@file_path, col_sep: col_sep, headers: true, encoding: 'utf-8') do |csv_row|
            if options.blank?
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

Scruber::Helpers::DictionaryReader.add(:csv, Scruber::Helpers::DictionaryReader::Csv)