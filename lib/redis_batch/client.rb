require './lib/redis_batch/configurable'
require 'singleton'

module RedisBatch
  class Client
    include Singleton
    extend RedisBatch::Configurable

    def initialize(configuration)
      if configuration.redis.respond_to?(:with)
        @connection_pool = configuration.redis
      else
        @connection_pool = ConnectionPool.new(size: 1, timeout: 1) {
          configuration.redis
        }
      end
    end

    def ping
      @connection_pool.with(&:ping)
    end

    def with(...)
      @connection_pool.with(...)
    end

    def pool
      @connection_pool
    end
  end
end
