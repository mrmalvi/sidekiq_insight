# frozen_string_literal: true

require "sidekiq_insight/version"
require "sidekiq_insight/metrics"
require "sidekiq_insight/configuration"
require "sidekiq_insight/storage"
require "sidekiq_insight/server_middleware"
require "sidekiq_insight/request_middleware"
require "sidekiq_insight/leak_detector"
require "sidekiq_insight/engine" if defined?(Rails)

module SidekiqInsight
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    def redis
      @redis ||= Redis.new(url: configuration&.redis_url || ENV['REDIS_URL'] || 'redis://127.0.0.1:6379/0')
    end

    def storage
      @storage ||= Storage.new(redis: redis, prefix: configuration&.prefix || 'sidekiq_insight:')
    end

    def detector
      @detector ||= LeakDetector.new(storage: storage)
    end
  end
end
