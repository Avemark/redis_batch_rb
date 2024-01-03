require "spec_helper"

RSpec.describe RedisBatch::Client do
  it "Wraps a redis client" do
    redis_client = RedisBatch::Client.configuration.redis
    allow(redis_client).to receive(:ping).and_return('OK')

    ping_response = RedisBatch::Client.instance.ping

    expect(RedisBatch::Client.configuration.redis).to be(redis_client)
    expect(ping_response).to eq('OK')
    expect(redis_client).to have_received(:ping)
  end
end
