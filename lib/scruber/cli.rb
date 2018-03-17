require "thor"
require "scruber"
require "scruber/cli/project_generator"
require "scruber/app_searcher"

module Scruber
  module CLI

    class Root < Thor
     def self.exit_on_failure?
        true
      end

      register(ProjectGenerator, "new", "new PATH", "Create new project")

      desc 'start', 'Run scraper'
      def start(name)
        if defined?(APP_PATH)
          # raise ::Thor::Error, "ERROR: Scruber project not found." unless File.exist?(File.expand_path('config/application', Dir.pwd))
          scraper_path = Scruber::AppSearcher.find_scraper(name, APP_PATH)
          raise ::Thor::Error, "ERROR: Scraper not found." if scraper_path.nil?
          say "booting..."
          require APP_PATH
          Dir[File.expand_path('../initializers/*.rb', APP_PATH)].sort.each do |i|
            require i
          end
          say "starting #{name}"
          ENV['SCRUBER_SCRAPER_NAME'] = name
          require scraper_path
        else
          Scruber::AppSearcher.exec_app(name)
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