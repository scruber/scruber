module Scruber
  module Helpers
    class UserAgentRotator

      class UserAgent
        attr_accessor :name, :tags

        def initialize(name, options={})
          @name = name
          raise Scruber::ArgumentError.new("You need to specify name") if @name.nil? || @name.empty?
          @tags = options.fetch(:tags){ [] } || []
          if !@tags.is_a?(Array)
            @tags = [@tags]
          end
          @tags = @tags.compact.map(&:to_sym)
        end

        def id
          @name
        end
      end

      class Configuration
        include Scruber::Core::Extensions::Loop::CoreMethods

        attr_reader :user_agents, :tags

        def initialize
          @tags = :all
          @user_agents = []
        end

        def configure(&block)
          instance_eval &block
        end

        def clean
          @user_agents = []
        end

        def add(name, options={})
          ua = UserAgent.new(name, options)
          @user_agents.push ua
        end

        def set_filter(tags)
          @tags = tags
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

        def next(tags=nil)
          raise Scruber::ArgumentError.new("UserAgent rotator not configured") if @configuration.nil?
          tags = @configuration.tags if tags.nil? || tags.empty?
          user_agents = get_collection(tags)
          if @cursor.nil? || @cursor >= user_agents.count-1
            @cursor = 0
          else
            @cursor += 1
          end
          user_agents[@cursor].name
        end

        private

          def get_collection(tags)
            if tags == :all
              @configuration.user_agents
            else
              if !tags.is_a?(Array)
                tags = [tags]
              end
              tags = tags.compact.map(&:to_sym)
              @configuration.user_agents.select{|ua| tags.all?{|t| ua.tags.include?(t) } }
            end
          end
      end
    end
  end
end
