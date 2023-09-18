// Store mod locals and variables in this file

locals {
  // Benchmarks and controls for specific services should override the "service" tag
  github_common_tags = {
    plugin   = "github"
    service  = "GitHub"
  }

  benchmark_all_mod_search_query    = "in:name steampipe-mod- is:public archived:false org:turbot org:ellisvalentiner org:ernw org:francois2metz org:ip2location org:kaggrwal org:marekjalovec org:mr-destructive org:solacelabs org:theapsgroup org:tomba-io"
  benchmark_turbot_mod_search_query = "in:name steampipe-mod- is:public archived:false org:turbot"

  benchmark_all_plugin_search_query    = "in:name steampipe-plugin- is:public archived:false org:solacelabs org:theapsgroup org:tomba-io"
  benchmark_turbot_plugin_search_query = "in:name steampipe-plugin- is:public archived:false org:turbot"

  dashboard_issue_search_query        = "org:turbot is:open is:public archived:false"
  dashboard_pull_request_search_query = "org:turbot is:open is:public archived:false -author:app/dependabot"
}
