require './lib/redis_batch/configurable'
require 'singleton'

module RedisBatch
  class Client
    include Singleton
    extend RedisBatch::Configurable

    def initialize(configuration)
      @redis_client = configuration.redis
    end

    def respond_to_missing?(...)
      @redis_client.respond_to?(...)
    end

    def method_missing(method, *args, **kwargs, &block)
      if @redis_client.respond_to?(method)
        @redis_client.send(method, *args, **kwargs, &block)
      else
        super
      end
    end
  end
end
