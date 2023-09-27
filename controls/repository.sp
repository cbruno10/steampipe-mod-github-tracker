benchmark "repository_steampipe_checks" {
  title = "Steampipe Repository Checks"
  children = [
    benchmark.repository_steampipe_core_checks,
    benchmark.repository_steampipe_mod_checks,
    benchmark.repository_steampipe_plugin_checks
  ]

  tags = merge(local.github_repository_common_tags, {
    type = "Benchmark"
  })
}
