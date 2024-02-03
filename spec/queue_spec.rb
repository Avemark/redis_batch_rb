require "spec_helper"

DeliberateTestError = Class.new(StandardError)

RSpec.describe RedisBatch::Queue do
  let(:redis_client) { RedisBatch.configuration.redis }
  describe "#add" do
    it "Adds any number of elements" do
      redis_key = "RedisBatch/add_test_queue"
      redis_client.with { |redis| redis.del(redis_key) }
      queue = RedisBatch::Queue.new("add_test")

      queue.add "foo"
      queue.add "bar", "baz"

      queue_contents = redis_client.with { |redis| redis.lrange(redis_key, 0, -1) }

      expect(queue_contents).to eq(["foo", "bar", "baz"])
    end
  end

  describe "#take" do
    it "takes any number of elements" do
      redis_key = "RedisBatch/take_test_queue"
      redis_takeout_key = "RedisBatch/take_test_takeout_#{Thread.current.native_thread_id}"
      redis_client.with do |redis|
        redis.del(redis_key)
        redis.del(redis_takeout_key)
        redis.rpush redis_key, ["foo", "bar", "baz"]
      end

      queue = RedisBatch::Queue.new("take_test")

      queue.take(count: 2) do |elements|
        expect(elements).to eq(["foo", "bar"])

        expect(queue.send(:take_key)).to eq(redis_takeout_key)

        takeout_queue_contents = redis_client.with { |redis| redis.lrange(redis_takeout_key, 0, -1)}
        expect(takeout_queue_contents).to eq(elements)

        base_queue_contents = redis_client.with { |redis| redis.lrange(redis_key, 0, -1)}
        expect(base_queue_contents).to eq(["baz"])
      end

      takeout_queue_contents = redis_client.with { |redis| redis.lrange(redis_takeout_key, 0, -1)}
      expect(takeout_queue_contents).to be_empty

      base_queue_contents = redis_client.with { |redis| redis.lrange(redis_key, 0, -1)}
      expect(base_queue_contents).to eq(["baz"])
    end

    it "restores elements on failure" do
      redis_key = "RedisBatch/take_test_queue"
      redis_takeout_key = "RedisBatch/take_test_takeout_#{Thread.current.native_thread_id}"
      redis_client.with do |redis|
        redis.del(redis_key)
        redis.del(redis_takeout_key)
        redis.rpush redis_key, ["foo", "bar", "baz"]
      end

      queue = RedisBatch::Queue.new("take_test")

      expect do
        queue.take(count: 2) do |elements|
          expect(elements).to eq(["foo", "bar"])

          expect(queue.send(:take_key)).to eq(redis_takeout_key)

          takeout_queue_contents = redis_client.with { |redis| redis.lrange(redis_takeout_key, 0, -1)}
          expect(takeout_queue_contents).to eq(elements)

          base_queue_contents = redis_client.with { |redis| redis.lrange(redis_key, 0, -1)}
          expect(base_queue_contents).to eq(["baz"])

          raise DeliberateTestError, "Any error occurs"
        end
      end.to raise_error(DeliberateTestError)

      takeout_queue_contents = redis_client.with { |redis| redis.lrange(redis_takeout_key, 0, -1)}
      expect(takeout_queue_contents).to be_empty

      base_queue_contents = redis_client.with { |redis| redis.lrange(redis_key, 0, -1)}
      expect(base_queue_contents).to eq(["foo", "bar", "baz"])
    end
  end
end
