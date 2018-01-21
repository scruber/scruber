require "thor"
require "crawley"
require "crawley/cli/project_generator"

module Crawley
  module CLI

    class Root < Thor
     def self.exit_on_failure?
        true
      end

      register(ProjectGenerator, "new", "new PATH", "Create new project")

      desc 'start', 'Run scraper'
      def start(name)
        raise ::Thor::Error, "ERROR: Crawley project not found." unless File.exist?('config/application.rb')
        raise ::Thor::Error, "ERROR: Scraper not found." unless File.exist?('./scrapers/'+name+'.rb')
        say "booting env"
        require './config/application.rb'
        say "starting #{name}"
        require './scrapers/'+name+'.rb'
      end

      desc 'version', 'Display version'
      map %w[-v --version] => :version
      def version
        say "Crawley #{VERSION}"
      end
    end
  end
end