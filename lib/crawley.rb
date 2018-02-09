require "crawley/version"
require 'nokogiri'
require 'pickup'

require "crawley/fetcher"
require "crawley/fetcher/typhoeus_fetcher"

require "crawley/queue_driver"
require "crawley/queue_driver/base"
require "crawley/queue_driver/simple"

require "crawley/core/page_format"
require "crawley/core/page_format/base"
require "crawley/core/page_format/xml"
require "crawley/core/page_format/html"

require "crawley/core/extensions/base"
require "crawley/core/extensions/loop"

# require "crawley/core/configuration"
# require "crawley/core/configuration"

module Crawley
  class ArgumentError < ::ArgumentError; end
  module Core
    autoload :Configuration, "crawley/core/configuration"
    autoload :Crawler,       "crawley/core/crawler"
  end

  module Helpers
    autoload :UserAgentRotator,   "crawley/helpers/user_agent_rotator"
    autoload :ProxyRotator,       "crawley/helpers/proxy_rotator"
    autoload :DictionaryReader,   "crawley/helpers/dictionary_reader"
    module DictionaryReader
      autoload :Xml,              "crawley/helpers/dictionary_reader/xml"
      autoload :Csv,              "crawley/helpers/dictionary_reader/csv"
    end
  end

  class << self
    attr_writer :configuration

    def run(options={}, &block)
      raise "You need a block to build!" unless block_given?

      Core::Crawler.new(options).run(&block)
    end

    def configuration
      @configuration ||= Core::Configuration.new
    end

    def configure(&block)
      yield configuration
    end
  end
end
