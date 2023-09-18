// Benchmarks and controls for specific services should override the "service" tag
locals {
  github_common_tags = {
    plugin   = "github"
    service  = "GitHub"
  }

  # TODO: Use these locals when extra space before colons is fixed
  /*
  benchmark_mod_query = "in:name steampipe-mod- is:public org:turbot org:ellisvalentiner org:ernw org:francois2metz org:ip2location org:kaggrwal org:marekjalovec org:mr-destructive org:solacelabs org:theapsgroup org:tomba-io"
  benchmark_plugin_query = "in:name steampipe-plugin- is:public org:turbot org:ellisvalentiner org:ernw org:francois2metz org:ip2location org:kaggrwal org:marekjalovec org:mr-destructive org:solacelabs org:theapsgroup org:tomba-io"
  dashboard_query = "org:turbot is:open is:public"
  */
}

mod "github_tracker" {
  # hub metadata
  title         = "GitHub Tracker"
  description   = "Track GitHub repository configurations and open issues and PRs."
  color         = "#191717"
}
