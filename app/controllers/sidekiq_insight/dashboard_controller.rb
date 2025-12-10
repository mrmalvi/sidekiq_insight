module SidekiqInsight
  class DashboardController < BaseController
    def index
      @jobs = SidekiqInsight.storage.top_jobs(50)
      @alerts = SidekiqInsight.detector.recent_alerts(20)
    end

    def show
      key = params[:job]
      @samples = SidekiqInsight.storage.recent(key, 200)
      @leak = SidekiqInsight::Metrics.detect_leak(@samples)
    end

    def clear
      SidekiqInsight.storage.clear_all
      redirect_to sidekiq_insight.root_path, notice: "Cleared profiler data"
    end
  end
end
