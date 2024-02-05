module RedisBatch
  class Queue
    def initialize(namespace = self.class.name)
      @namespace = namespace
      @client = Client.instance
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
        redis.multi do |transaction|
          count.times.map { transaction.lmove(queue_key, take_key, :left, :right) }
        end
      end
      yield values
      client.with { |redis| redis.del(take_key) }
    rescue => error
      client.with { |redis| abort_processing(take_key, redis) }
      raise error
    end

    private

    def abort_processing(key, redis)
      recover_count = redis.llen(key)
      redis.multi do |transaction|
        recover_count.times { transaction.lmove(take_key, queue_key, :right, :left) }
      end
    end

    def queue_key
      @queue_key ||= "RedisBatch/#{@namespace}_queue"
    end

    def take_key
      @take_key ||= "RedisBatch/#{@namespace}_takeout_#{Thread.current.native_thread_id}"
    end
  end
end
