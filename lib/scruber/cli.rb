require "thor"
require "scruber"
require "scruber/cli/project_generator"
require "scruber/cli/generators"
require "scruber/app_searcher"

module Scruber
  module CLI

    class Root < Thor
      def self.exit_on_failure?
        true
      end

      register ProjectGenerator, "new", "new PATH", "Create new project"
      register Generators, 'generate', 'generate [GENERATOR]', 'Generate something'

      desc 'start', 'Run scraper'
      method_option :silent, :type => :boolean, :aliases => '-s', default: false
      def start(name)
        if defined?(APP_PATH)
          scraper_path = Scruber::AppSearcher.find_scraper(name, APP_PATH)
          raise ::Thor::Error, "ERROR: Scraper not found." if scraper_path.nil?
          say "booting..."
          require APP_PATH
          Dir[File.expand_path('../initializers/*.rb', APP_PATH)].sort.each do |i|
            require i
          end
          ENV['SCRUBER_SCRAPER_NAME'] = File.basename(scraper_path).gsub(/\.rb\Z/, '').underscore
          say "starting #{ENV['SCRUBER_SCRAPER_NAME']}"
          
          Scruber.configuration.silent = options[:silent]
          require scraper_path
        else
          raise ::Thor::Error, "ERROR: Scruber project not found."
        end
      end

      desc 'version', 'Display version'
      map %w[-v --version] => :version
      def version
        say "Scruber #{VERSION}"
      end
    end
  end
end