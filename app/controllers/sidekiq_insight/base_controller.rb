module SidekiqInsight
  class BaseController < ActionController::Base
    protect_from_forgery with: :exception
    layout "sidekiq_insight/sidekiq_insight"
  end
end
