# frozen_string_literal: true

module SidekiqInsight
  class Configuration
    attr_accessor :redis_url, :prefix

    def initialize
      @redis_url = ENV['REDIS_URL'] || 'redis://127.0.0.1:6379/0'
      @prefix = 'sidekiq_insight:'
    end
  end
end
