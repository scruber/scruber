module Scruber
  module Helpers
    class ProxyRotator

      class Proxy
        attr_accessor :host, :port, :user, :password, :probability, :type

        def initialize(proxy, options={})
          @host = proxy.split(':', 2).first
          raise Scruber::ArgumentError.new("You need to specify proxy address") if @host.nil? || @host.empty?
          @port = options.fetch(:port) { proxy.split(':', 2)[1] }.to_i rescue nil
          raise Scruber::ArgumentError.new("You need to specify :port for this proxy or pass full proxy address like 127.0.0.1:100") if @port.nil? || @port.zero?
          @type = options.fetch(:type) { 'http' }
          @user = options.fetch(:user) { nil }
          @password = options.fetch(:password) { nil }
          @probability = options.fetch(:probability) { 1 }
        end

        def id
          (@host + ':' + @port.to_s)
        end

        def address
          @host + ':' + @port.to_s
        end

        def http?
          @type == 'http'
        end

        def proxyuserpwd
          if @user.nil? || @user.empty?
            nil
          else
            "#{@user}:#{@password}"
          end
        end
      end

      class Configuration
        include Scruber::Core::Extensions::Loop::CoreMethods

        AVAILABLE_MODES=[:random, :round_robin]

        attr_reader :mode, :proxies, :proxy_keys, :pickup

        def initialize
          @mode = :round_robin
          @proxies = {}
          @proxy_keys = []
          @pickup = nil
        end

        def configure(&block)
          instance_eval &block
          rebuild_caches
        end

        def clean
          @proxies = {}
        end

        def add(proxy_address, options={})
          proxy = Proxy.new(proxy_address, options)
          @proxies[proxy.id] = proxy
        end

        def set_mode(mode)
          if AVAILABLE_MODES.include?(mode)
            @mode = mode
          else
            raise Scruber::ArgumentError.new("Wrong mode. Available modes: #{AVAILABLE_MODES}")
          end
        end

        private

          def rebuild_caches
            if @mode == :random
              @pickup = Pickup.new(@proxies.inject({}){ |acc,(k,p)| acc[p] = p.probability; acc })
            else
              @proxy_keys = @proxies.keys
            end
          end
      end

      class << self
        attr_writer :configuration
        attr_accessor :cursor

        def configuration
          @configuration ||= Configuration.new
        end

        def configure(&block)
          configuration.configure(&block)
        end

        def next(options={})
          # raise Scruber::ArgumentError.new("Proxy rotator not configured") if @configuration.nil?
          return nil if @configuration.nil?
          if @configuration.mode == :random
            @configuration.pickup.pick
          else
            if @cursor.nil? || @cursor >= @configuration.proxy_keys.count-1
              @cursor = 0
            else
              @cursor += 1
            end
            @configuration.proxies[@configuration.proxy_keys[@cursor]]
          end
        end
        alias_method :random, :next

        def find(id)
          @configuration.proxies[id] rescue nil
        end

        def configured?
          !@configuration.nil? && !@configuration.proxies.empty?
        end
      end
    end
  end
end