require "thor"
require 'thor/group'
require 'fileutils'

module Crawley
  class CLI < Thor
    class ProjectGenerator < Thor::Group
      include Thor::Actions
      # desc 'Create new project'
      
      argument :path
      class_option :queue, :default => 'simple', :aliases => '-q'

      def self.source_root
        File.dirname(__FILE__) + '/templates'
      end

      def mkdir
        FileUtils.mkdir_p(path)
      end

      def create_test_file
        template 'Gemfile.tt', path+'/Gemfile'
      end

      # def create_config_file
      #   copy_file 'config.yml', 'config/mygem.yml'
      # end

      # def create_git_files
      #   copy_file 'gitignore', '.gitignore'
      #   create_file 'images/.gitkeep'
      #   create_file 'text/.gitkeep'
      # end

      # def create_output_directory
      #   empty_directory 'output'
      # end
    end
  end
end
# module Crawley
#   class CLI < Thor
#     class ProjectGenerator < Thor::Group
#       include Thor::Actions
#       desc 'Generate a new filesystem structure'

#       alias :new

#       argument :path
#       argument :queue_name
#       argument :queue, :default => 'simple', :aliases => '-q'

#       def self.source_root
#         File.dirname(__FILE__) + '/templates'
#       end

#       def mkdir
#         FileUtils.mkdir_p(path)
#       end

#       def create_test_file
#         template 'Gemfile.tt', path+'/Gemfile'
#       end

#       # def create_config_file
#       #   copy_file 'config.yml', 'config/mygem.yml'
#       # end

#       # def create_git_files
#       #   copy_file 'gitignore', '.gitignore'
#       #   create_file 'images/.gitkeep'
#       #   create_file 'text/.gitkeep'
#       # end

#       # def create_output_directory
#       #   empty_directory 'output'
#       # end
#     end
#   end
# end