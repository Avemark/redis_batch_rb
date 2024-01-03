require "spec_helper"

RSpec.describe RedisBatch::Client do
  it "Wraps a redis client" do
    ping_response = RedisBatch::Client.instance.ping

    expect(RedisBatch::Client.instance.pool).to be(RedisBatch::Client.configuration.redis)
    expect(ping_response).to eq('PONG')
  end
end
