// Benchmarks and controls for specific services should override the "service" tag
locals {
  # TODO: Use these locals when extra space before colons is fixed
  benchmark_mod_query = "in:name steampipe-mod- is:public org:turbot org:ellisvalentiner org:ernw org:francois2metz org:ip2location org:kaggrwal org:marekjalovec org:mr-destructive org:solacelabs org:theapsgroup org:tomba-io"
  benchmark_plugin_query = "in:name steampipe-plugin- is:public org:turbot org:ellisvalentiner org:ernw org:francois2metz org:ip2location org:kaggrwal org:marekjalovec org:mr-destructive org:solacelabs org:theapsgroup org:tomba-io"
  dashboard_query = "org:turbot is:open is:public"
}
