require "get_process_mem"

module SidekiqInsight
  class ServerMiddleware
    def call(worker, job, queue)
      pm_before = GetProcessMem.new
      rss_before = pm_before.mb * 1024.0
      cpu_before = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
      t_before = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      yield

      t_after = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      cpu_after = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
      pm_after = GetProcessMem.new
      rss_after = pm_after.mb * 1024.0

      sample = {
        job_class: worker.class.name,
        queue: queue,
        args: job["args"],
        started_at: Time.now.utc.iso8601,
        wall_ms: (t_after - t_before) * 1000.0,
        cpu_ms: (cpu_after - cpu_before) * 1000.0,
        rss_kb: (rss_after - rss_before)
      }

      SidekiqInsight.storage.push_sample(worker.class.name, sample)
    rescue => e
      raise
    end
  end
end
