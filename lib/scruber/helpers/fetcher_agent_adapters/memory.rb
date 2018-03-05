module Scruber
  module Helpers
    module FetcherAgentAdapters
      class Memory < AbstractAdapter
        def initialize(options={})
          super(options)
          @id = Time.now.to_i.to_s+'_'+rand(1_000..999_999).to_s if @id.nil?
        end

        def save
          Scruber::Helpers::FetcherAgentAdapters::Memory.store(self)
        end

        def delete
          Scruber::Helpers::FetcherAgentAdapters::Memory.delete(self)
        end

        class << self
          def find(id)
            _collection[id]
          end

          def _collection
            @_collection ||= {}
          end

          def store(fetcher_agent)
            _collection[fetcher_agent.id] = fetcher_agent
          end

          def delete(fetcher_agent)
            _collection.delete fetcher_agent.id
          end
        end

      end
    end
  end
end

Scruber::Helpers::FetcherAgent.add_adapter(:memory, Scruber::Helpers::FetcherAgentAdapters::Memory)