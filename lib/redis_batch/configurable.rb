require 'ostruct'

module RedisBatch
  # Add configuration to a Singleton
  module Configurable
    class Configuration
      def initialize(redis:)
        @redis = redis
      end

      attr_accessor :redis
    end

    def configure
      yield configuration
    end

    def reset_configuration
      @configuration = nil
    end

    def configuration
      @configuration ||= Configuration.new(**default_configuration)
    end

    private

    def new
      super(configuration)
    end

    def default_configuration
      {
        redis: Redis.new
      }
    end
  end
end
