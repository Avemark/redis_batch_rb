require 'redis'
require './lib/redis_batch/configurable'
require './lib/redis_batch/client'
require 'singleton'

module RedisBatch
  Error = Class.new(StandardError)

  def self.configure(&block)
    Client.configure { |config| block.call(config) }
  end

  def self.configuration
    Client.configuration
  end

  class Queue
    def initialize(namespace = self.class.name)
      @namespace = namespace
      @client = Client.instance
    end

    def add(*items)
      @client.rpush(queue_key, items)
    end

    def count
      @client.llen(queue_key)
    end

    def processing?
      @client.keys("#{@namespace}_takeout_*").any?
    end

    def take(count: 1, client: @client)
      values = client.with do |redis|
        redis.multi do |transaction|
          count.times.map { transaction.lmove(queue_key, take_key, :left, :right) }
        end
      end
      yield values
      client.with { |redis| redis.del(take_key) }
    rescue => error
      client.with do |redis|
        redis.multi do |transaction|
          count.times { transaction.lmove(take_key, queue_key, :right, :left) }
        end
      end
      raise error
    end

    private

    def queue_key
      @queue_key ||= "RedisBatch/#{@namespace}_queue"
    end

    def take_key
      @take_key ||= "redis_batch/#{@namespace}_takeout_#{Thread.current.native_thread_id}"
    end
  end
end
