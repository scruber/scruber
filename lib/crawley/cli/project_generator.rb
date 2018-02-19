require "thor"
require 'thor/group'
require 'fileutils'

module Crawley
  module CLI
    class ProjectGenerator < Thor::Group
      include Thor::Actions

      argument :path
      class_option :queue, :default => 'memory', :aliases => '-q'
      class_option :fetcher_agent, :default => 'memory', :aliases => '-fa'

      def self.source_root
        File.dirname(__FILE__) + '/templates'
      end

      def create_directories
        raise ::Thor::Error, "ERROR: #{path} already exists." if File.exist?(path)
        say "Creating crawley project at #{path}"
        FileUtils.mkdir_p(path)
      end

      def create_files
        template 'Gemfile.tt', path+'/Gemfile'
        template 'gitignore.tt', path+'/.gitignore'
        template 'bin/crawley.tt', path+'/bin/crawley'
        template 'application.tt', path+'/config/application.rb'
        template 'boot.tt', path+'/config/boot.rb'
        template 'boot.tt', path+'/config/boot.rb'
        template 'initializers/proxies.tt', path+'/config/initializers/proxies.rb'
        template 'initializers/user_agents.tt', path+'/config/initializers/user_agents.rb'
        template 'scrapers/sample.tt', path+'/scrapers/sample.rb'
      end

      def init_project
        inside path do
          run "bundle"
        end
      end

      def print_instructions
        say "Run `crawley start sample` to run sample scraper"
      end
    end
  end
end
