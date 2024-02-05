require 'redis'
require 'redis_batch/configurable'
require 'redis_batch/lua'
require 'redis_batch/client'
require 'redis_batch/queue'

module RedisBatch
  Error = Class.new(StandardError)

  def self.configure(&block)
    Client.configure { |config| block.call(config) }
  end

  def self.configuration
    Client.configuration
  end
end
