// Benchmarks and controls for specific services should override the "service" tag
locals {
  github_common_tags = {
    category = "Insights"
    plugin   = "github"
    service  = "GitHub"
  }
}

mod "github_tracker" {
  # hub metadata
  title         = "GitHub Tracker"
  description   = "Track GitHub open issues and PRs."
  color         = "#191717"
}
