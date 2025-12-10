module SidekiqInsight
  class LeakDetector
    def initialize(storage:)
      @storage = storage
    end

    # check last N samples for rising memory trend
    def detect(key, window = 20)
      samples = @storage.recent(key, window)
      SidekiqInsight::Metrics.detect_leak(samples)
    end

    def recent_alerts(limit = 20)
      jobs = @storage.top_jobs(100)
      alerts = []
      jobs.each do |j|
        leak = detect(j[:key], 50)
        alerts << { job: j[:key], leak: leak } if leak
        break if alerts.size >= limit
      end
      alerts
    end
  end
end
