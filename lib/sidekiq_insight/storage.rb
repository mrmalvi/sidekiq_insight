require "json"

module SidekiqInsight
  class Storage
    def initialize(redis:, prefix: "sidekiq_insight:")
      @redis = redis
      @prefix = prefix
    end

    def push_sample(key, sample)
      redis_key = namespaced("samples:#{key}")
      @redis.lpush(redis_key, sample.to_json)
      @redis.ltrim(redis_key, 0, 999)
      @redis.hincrby(namespaced("counts"), key, 1)
      @redis.hincrbyfloat(namespaced("cpu"), key, sample[:cpu_ms].to_f)
      @redis.hincrbyfloat(namespaced("mem"), key, sample[:rss_kb].to_f)
    end

    def top_jobs(limit = 20)
      counts = @redis.hgetall(namespaced("counts"))
      return [] if counts.empty?
      counts.map do |k,v|
        c = v.to_i
        { key: k, count: c, avg_cpu_ms: @redis.hget(namespaced("cpu"), k).to_f / [c,1].max, avg_mem_kb: @redis.hget(namespaced("mem"), k).to_f / [c,1].max }
      end.sort_by { |h| -h[:avg_cpu_ms] }[0, limit]
    end

    def recent(key, limit = 100)
      arr = @redis.lrange(namespaced("samples:#{key}"), 0, limit-1)
      arr.map { |j| JSON.parse(j, symbolize_names: true) }
    end

    def clear_all
      keys = @redis.keys("#{ @prefix }*")
      @redis.del(*keys) if keys.any?
    end

    private

    def namespaced(suffix)
      "#{@prefix}#{suffix}"
    end
  end
end
