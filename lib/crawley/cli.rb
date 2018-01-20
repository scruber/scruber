require "thor"
require "crawley"
# require "crawley/cli/project_generator"

module Crawley
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    # desc "new", "Create new project"
    # option :queue, :default => 'simple', :aliases => '-q'
    # def new(path)
    #   path = File.expand_path(path)
    #   raise Error, "ERROR: #{path} already exists." if File.exist?(path)

    #   say "Creating crawley project at #{path}"
    #   say options
    #   g = Crawley::CLI::ProjectGenerator.new([path]).invoke_all
    #   # g.path = path
    # end
    register(Crawley::CLI::ProjectGenerator, "new", "new", "Create new project")


    desc 'version', 'Display version'
    map %w[-v --version] => :version
    def version
      say "Crawley #{VERSION}"
    end
  end
end