module RedisBatch
  class Queue
    def initialize(namespace = self.class.name)
      @namespace = namespace
      @client = Client.instance
      @client.with  { |redis| Functions.function_load(redis) }
    end

    def add(*items)
      @client.with { |redis| redis.rpush(queue_key, items) }
    end

    def count
      @client.with { |redis| redis.llen(queue_key) }
    end

    def self.processing?
      @client.with { |redis| redis.keys("#{@namespace}_takeout_*").any? }
    end

    def abort_all
      return unless processing?
      @client.with do |redis|
        redis.keys("#{@namespace}_takeout_*").each do |key|
          abort_processing(key, redis)
        end
      end
    end

    def take(count: 1, client: @client)
      values = client.with do |redis|
        redis.call("FCALL", "rb_lmove", 2, queue_key, take_key, count)
      end
      yield values
      client.with { |redis| redis.del(take_key) }
    rescue => error
      client.with { |redis| abort_processing(take_key, redis) }
      raise error
    end

    private

    def abort_processing(key, redis)
      redis.call("FCALL", "rb_lrestore", 2, key, queue_key)
    end

    def queue_key
      @queue_key ||= "RedisBatch/#{@namespace}_queue"
    end

    def take_key
      @take_key ||= "RedisBatch/#{@namespace}_takeout_#{Thread.current.native_thread_id}"
    end
  end
end
