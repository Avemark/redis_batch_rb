require 'redis'
require './lib/redis_batch/configurable'
require './lib/redis_batch/client'
require './lib/redis_batch/functions'
require './lib/redis_batch/queue'

module RedisBatch
  Error = Class.new(StandardError)

  def self.configure(&block)
    Client.configure { |config| block.call(config) }
  end

  def self.configuration
    Client.configuration
  end
end
