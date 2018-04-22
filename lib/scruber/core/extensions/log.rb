module Scruber
  module Core
    module Extensions
      # 
      # Logging class
      # Allows to write logs to file and console, depends on configuration
      # 
      # @author Ivan Goncharov
      # 
      class Log < Base
        module CoreMethods
          # 
          # Writing log
          # 
          # @param text [String] text
          # @param color [Symbol] color of text to write
          # 
          # @return [void]
          def log(text, color=:white)
            Scruber.logger.info(scraper_name){ text } rescue nil
            if @progressbar
              @progressbar.print "#{Paint[text, color]}\n"
            end
          end

          # 
          # Setting status for console progressbar
          # 
          # @param text [String] text
          # 
          # @return [void]
          def set_status(text)
            @proggress_status = text
          end
        end
      end
    end
  end
end
