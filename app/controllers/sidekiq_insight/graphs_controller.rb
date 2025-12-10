module SidekiqInsight
  class GraphsController < BaseController
    def cpu
      @jobs = SidekiqInsight.storage.top_jobs(50)
      @cpu_chart = build_series(:cpu_ms)
    end

    def rss
      @jobs = SidekiqInsight.storage.top_jobs(50)
      @rss_chart = build_series(:rss_kb)
    end

    def wall
      @jobs = SidekiqInsight.storage.top_jobs(50)
      @wall_chart = build_series(:wall_ms)
    end

    def leaks
      @jobs = SidekiqInsight.storage.top_jobs(50)
      @leak_jobs = @jobs.select do |j|
        samples = SidekiqInsight.storage.recent(j[:key], 200)
        SidekiqInsight::Metrics.detect_leak(samples)
      end
    end

    private

    def build_series(metric_sym)
      data = {}
      SidekiqInsight.storage.top_jobs(20).each do |job|
        samples = SidekiqInsight.storage.recent(job[:key], 200)
        series = samples.reverse.map { |s| [s[:started_at], s[metric_sym].to_f] }
        data[job[:key]] = series
      end
      data
    end
  end
end
