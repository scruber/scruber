module Scruber
  module AppSearcher

    extend self

    RUBY = Gem.ruby
    EXECUTABLES = ["bin/scruber"]

    def exec_app
      original_cwd = Dir.pwd

      loop do
        if exe = find_executable
          exec RUBY, exe, *ARGV
          break # non reachable, hack to be able to stub exec in the test suite
        end

        # If we exhaust the search there is no executable, this could be a
        # call to generate a new application, so restore the original cwd.
        Dir.chdir(original_cwd) && return if Pathname.new(Dir.pwd).root?

        # Otherwise keep moving upwards in search of an executable.
        Dir.chdir("..")
      end
      true
    end

    def find_scraper(name, app_path)
      [
        File.expand_path('../../scrapers/'+name+'.rb', app_path),
        File.expand_path('../../scrapers/'+name, app_path),
      ].find{|f| File.exists?(f) }
    end

    def find_executable
      EXECUTABLES.find { |exe| File.file?(exe) }
    end
  end
end