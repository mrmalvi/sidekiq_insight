# SidekiqInsight

**SidekiqInsight** is a lightweight performance monitoring engine for Sidekiq.
It records CPU usage, wall time, memory (RSS), arguments, and detects memory-leak patterns — all displayed in a clean, Bootstrap-based dashboard.

---

## 🚀 Installation

Add this line to your application's Gemfile:

```ruby
gem "sidekiq_insight"
```

Then:

```bash
bundle install
```

---

## ⚙️ Configuration (Required)

Create the initializer:

```
config/initializers/sidekiq_insight.rb
```

Add:

```ruby
SidekiqInsight.configure do |config|
  config.redis_url = "redis://127.0.0.1:6379/0"
end
```

SidekiqInsight uses Redis to store:

- job samples
- aggregated metrics
- leak alerts

---

## 🛣 Mounting the Engine

Add this to your Rails **config/routes.rb**:

```ruby
mount SidekiqInsight::Engine => "/sidekiq_insight"
```

Then visit:

```
http://localhost:3000/sidekiq_insight
```

---

## 📊 What SidekiqInsight Monitors

### For every Sidekiq job run, it records:

- `started_at`
- `wall_ms`
- `cpu_ms`
- `rss_kb`
- job arguments
- execution count

### Aggregated metrics:

- average CPU
- average memory usage
- execution counts

### Memory leak detection:

SidekiqInsight automatically analyzes RSS trends:

```ruby
SidekiqInsight::Metrics.detect_leak(samples)
```

Jobs with a positive trend appear under **Leak Alerts**.

---

## 🖥 Dashboard Pages

### **Top Jobs Metrics**
- `/sidekiq_insight/graphs/cpu`
- `/sidekiq_insight/graphs/rss`
- `/sidekiq_insight/graphs/wall`

Each page shows sortable metrics and Chart.js graphs.

---

### **Leak Alerts**
Lists jobs where memory leak patterns are detected.

---

### **Job Details**
View every sample recorded for a job:

- CPU chart
- Memory (RSS) chart
- Wall time chart
- Raw arguments (JSON)

---

## ⚡ Adding Middleware (Highly Recommended)

Inside `config/initializers/sidekiq.rb` or `sidekiq.yml`:

```ruby
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add SidekiqInsight::ServerMiddleware
  end
end
```

This ensures job metrics are captured.

---

## 🔧 Utility Methods

### Clear all stored metrics:

```ruby
SidekiqInsight.storage.clear_all
```

Useful during development.

---

## 📦 Directory Structure

```
sidekiq_insight/
  app/
    controllers/sidekiq_insight/
    views/sidekiq_insight/
  lib/
    sidekiq_insight/
      metrics.rb
      storage.rb
      server_middleware.rb
      request_middleware.rb
      version.rb
    sidekiq_insight.rb
  config/routes.rb
```

---

## 🎨 Frontend

The dashboard UI uses:

- **Bootstrap 5**
- **Chart.js graphs**
- **Responsive tables/cards**
- **Leak alerts highlighting**

No configuration needed out of the box.

---

## 📝 Example Output

Metrics include data like:

```json
{
  "started_at": "2025-02-01T10:20:30Z",
  "wall_ms": 52.0,
  "cpu_ms": 13.5,
  "rss_kb": 242.1,
  "args": ["123", true]
}
```

---

## ❤️ Contributing

Pull requests are welcome!
Please open an issue first to discuss changes.

---

## 📜 License

MIT License

