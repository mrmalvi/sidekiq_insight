module SidekiqInsight
  module Metrics
    def self.detect_leak(samples)
      return false if samples.nil? || samples.size < 6
      # use first half vs last half
      half = samples.size / 2
      first = samples[0, half].map { |s| s[:rss_kb].to_f }
      last  = samples[half, half].map { |s| s[:rss_kb].to_f }
      return false if first.empty? || last.empty?
      first_avg = first.sum / first.size
      last_avg  = last.sum / last.size
      (last_avg - first_avg) > (first_avg * 0.2) # >20% increase indicates suspect
    end
  end
end
