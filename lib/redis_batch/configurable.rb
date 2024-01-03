require 'ostruct'

module RedisBatch
  # Add configuration to a Singleton
  module Configurable
    def configure
      yield configuration
    end

    def reset_configuration
      @configuration = nil
    end

    def configuration
      @configuration ||= OpenStruct.new(default_configuration)
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
