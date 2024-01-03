RSpec.describe RedisBatch::Queue do
  let(:redis_client) { RedisBatch.configuration.redis }
  describe "#add" do


    it "Adds any number of elements" do
      redis_key = "RedisBatch/add_test_queue"
      redis_client.del(redis_key)
      queue = RedisBatch::Queue.new("add_test")

      queue.add "foo"
      queue.add "bar", "baz"

      queue_contents = redis_client.lrange(redis_key, 0, -1)

      expect(queue_contents).to eq(["foo", "bar", "baz"])
    end
  end
end
