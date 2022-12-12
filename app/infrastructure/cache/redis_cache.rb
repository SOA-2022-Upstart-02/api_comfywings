# frozen_string_literal: true

require 'redis'

module ComfyWings
  module Cache
    # redis client utility
    class Client
      @redis = Redis.new(url: config.REDISCLOUD_URL)
    end

    def keys
      @redis.keys
    end

    def wipe
      keys.each { |key| @redis.del(key)}
    end
  end
end