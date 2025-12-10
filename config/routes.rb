SidekiqInsight::Engine.routes.draw do
  root to: "dashboard#index"
  get "/job", to: "dashboard#show", as: :job
  post "/clear", to: "dashboard#clear", as: :clear

  # Graphs
  get "/cpu", to: "graphs#cpu", as: :cpu
  get "/rss", to: "graphs#rss", as: :rss
  get "/wall", to: "graphs#wall", as: :wall
  get "/leaks", to: "graphs#leaks", as: :leaks
end
