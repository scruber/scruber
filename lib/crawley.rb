require "crawley/version"
require 'nokogiri'
require 'http-cookie'
require 'pickup'

require "crawley/fetcher"
require "crawley/fetcher_adapters/typhoeus_fetcher"

require "crawley/queue"
require "crawley/queue_adapters/abstract_adapter"
require "crawley/queue_adapters/memory"

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
    autoload :FetcherAgent,       "crawley/helpers/fetcher_agent"
    module FetcherAgentAdapters
      autoload :AbstractAdapter,  "crawley/helpers/fetcher_agent_adapters/abstract_adapter"
      autoload :Memory,           "crawley/helpers/fetcher_agent_adapters/memory"
    end
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
