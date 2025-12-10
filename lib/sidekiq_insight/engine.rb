require 'rails'
require "chartkick"
require "groupdate"

module SidekiqInsight
  class Engine < ::Rails::Engine
    isolate_namespace SidekiqInsight

    initializer 'sidekiq_insight.insert_middlewares' do |app|
      # insert request profiling into Rails middleware stack
      app.middleware.insert_before(0, SidekiqInsight::RequestMiddleware)

      # configure Sidekiq server middleware
      if defined?(Sidekiq)
        Sidekiq.configure_server do |config|
          config.server_middleware do |chain|
            chain.add SidekiqInsight::ServerMiddleware
          end
        end
      end
    end

    config.autoload_paths << root.join("app/helpers")
    config.autoload_paths << root.join("lib/sidekiq_insight")

    initializer "sidekiq_insight.assets" do |app|
      app.config.assets.precompile += %w[
        sidekiq_insight.js
        chart.js
        chartjs-adapter-date-fns.js
        chartkick.js
      ]
    end
  end
end
