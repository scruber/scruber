require "scruber/version"
require 'nokogiri'
require 'http-cookie'
require 'pickup'
require 'csv'
require 'active_support'
require 'active_support/core_ext/object'
require 'active_support/core_ext/hash'

require "scruber/fetcher"
require "scruber/fetcher_adapters/abstract_adapter"
require "scruber/fetcher_adapters/typhoeus_fetcher"

require "scruber/queue"
require "scruber/queue_adapters/abstract_adapter"
require "scruber/queue_adapters/memory"

require "scruber/core/page_format"
require "scruber/core/page_format/base"
require "scruber/core/page_format/xml"
require "scruber/core/page_format/html"

require "scruber/core/extensions/base"
require "scruber/core/extensions/loop"
require "scruber/core/extensions/csv_output"
require "scruber/core/extensions/queue_aliases"
require "scruber/core/extensions/parser_aliases"

require "scruber/helpers/dictionary_reader"
require "scruber/helpers/dictionary_reader/xml"
require "scruber/helpers/dictionary_reader/csv"

# require "scruber/core/configuration"
# require "scruber/core/configuration"

module Scruber
  class ArgumentError < ::ArgumentError; end
  module Core
    autoload :Configuration, "scruber/core/configuration"
    autoload :Crawler,       "scruber/core/crawler"
  end

  module Helpers
    autoload :UserAgentRotator,   "scruber/helpers/user_agent_rotator"
    autoload :ProxyRotator,       "scruber/helpers/proxy_rotator"
    autoload :FetcherAgent,       "scruber/helpers/fetcher_agent"
    module FetcherAgentAdapters
      autoload :AbstractAdapter,  "scruber/helpers/fetcher_agent_adapters/abstract_adapter"
      autoload :Memory,           "scruber/helpers/fetcher_agent_adapters/memory"
    end
  end

  class << self
    attr_writer :configuration

    def run(*args, &block)
      raise "You need a block to build!" unless block_given?

      Core::Crawler.new(*args).run(&block)
    end

    def configuration
      @configuration ||= Core::Configuration.new
    end

    def configure(&block)
      yield configuration
    end
  end
end
