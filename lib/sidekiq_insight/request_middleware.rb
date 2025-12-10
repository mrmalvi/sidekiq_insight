require "get_process_mem"

module SidekiqInsight
  class RequestMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      # ---- BEFORE REQUEST ----
      pm_before   = GetProcessMem.new
      rss_before  = pm_before.mb * 1024.0
      cpu_before  = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
      t_before    = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      status, headers, body = @app.call(env)

      # ---- AFTER REQUEST ----
      t_after   = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      cpu_after = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
      pm_after  = GetProcessMem.new
      rss_after = pm_after.mb * 1024.0

      req = Rack::Request.new(env)

      sample = {
        path: req.path,
        method: req.request_method,
        status: status,
        started_at: Time.now.utc.iso8601,
        wall_ms: (t_after - t_before) * 1000.0,
        cpu_ms: (cpu_after - cpu_before) * 1000.0,
        rss_kb: (rss_after - rss_before)
      }

      # 🚨 FIX — separate HTTP bucket
      SidekiqInsight.storage.push_sample("__http__#{req.path}", sample)

      [status, headers, body]
    end
  end
end
