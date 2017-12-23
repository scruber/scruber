require "thor"
require "crawley"

module Crawley
  class CLI < Thor
    desc "ipsum", "Lorem Ipsum text generator"
    def ipsum
      puts "absc"
    end
  end
end