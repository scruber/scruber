require "thor"
require 'fileutils'

module Scruber
  module CLI
    class Generators < Thor

      class ScraperGenerator < Thor::Group
        include Thor::Actions

        argument :name

        def self.source_root
          File.dirname(__FILE__) + '/templates'
        end

        def create_files
          if defined?(APP_PATH)
            scraper_path = Scruber::AppSearcher.find_scraper(name, APP_PATH)
            if scraper_path.present?
              raise ::Thor::Error, "ERROR: Scraper already exists" 
            end
            template 'scrapers/sample.tt', File.expand_path('../../scrapers/'+name+'.rb', APP_PATH)
          else
            raise ::Thor::Error, "ERROR: Scruber project not found."
          end
        end
      end

      register ScraperGenerator, 'scraper', 'scraper [NAME]', 'Generate scraper'
    end
  end
end
