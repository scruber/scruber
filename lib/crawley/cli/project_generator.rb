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
        FileUtils.mkdir_p(path+'/scrapers')
      end

      def create_files
        template 'bin/crawley.tt', path+'/bin/crawley'
        template 'Gemfile.tt', path+'/Gemfile'
        template 'application.tt', path+'/config/application.rb'
        template 'boot.tt', path+'/config/boot.rb'
        template 'gitignore.tt', path+'/.gitignore'
        template 'boot.tt', path+'/config/boot.rb'
        template 'initializers/proxies.tt', path+'/config/initializers/proxies.rb'
        template 'initializers/user_agents.tt', path+'/config/initializers/user_agents.rb'
      end

      def init_project
        inside path do
          run "bundle"
        end
      end
    end
  end
end
