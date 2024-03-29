dashboard "github_open_issue_pull_request_trends" {

  title = "Steampipe Open Issue and Pull Request Trends"

  tags = merge(local.github_common_tags, {
    type = "Dashboard"
  })

  container {

    chart {
      title = "Open CLI Issues Total Age (Days)"
      type  = "line"
      query = query.github_issue_cli_trend
      width = 6
    }

    chart {
      title = "Open CLI Pull Requests Total Age (Days)"
      type  = "line"
      query = query.github_pull_request_cli_trend
      width = 6
    }

    chart {
      title = "Open Plugin and Mod Issues Total Age (Days)"
      type  = "line"
      query = query.github_issue_plugin_mod_trend
      width = 6
    }

    chart {
      title = "Open Plugin and Mod Pull Requests Total Age (Days)"
      type  = "line"
      query = query.github_pull_request_plugin_mod_trend
      width = 6
    }
  }

}

query "github_issue_cli_trend" {
  sql = <<-EOQ
    select
      created_at as "Date",
      sum((r ->> 'Age in Days')::numeric) as "Days Open"
    from
      pipes_workspace_snapshot,
      jsonb_array_elements(data -> 'panels' -> 'github_tracker.table.container_dashboard_github_open_cli_issue_report_anonymous_container_0_anonymous_table_0' -> 'data' -> 'rows') as r
    where
      dashboard_name = 'github_tracker.dashboard.github_open_cli_issue_report'
    group by
      created_at
    order by
      created_at
  EOQ
}

query "github_pull_request_cli_trend" {
  sql = <<-EOQ
    select
      created_at as "Date",
      sum((r ->> 'Age in Days')::numeric) as "Days Open"
    from
      pipes_workspace_snapshot,
      jsonb_array_elements(data -> 'panels' -> 'github_tracker.table.container_dashboard_github_open_cli_pull_request_report_anonymous_container_0_anonymous_table_0' -> 'data' -> 'rows') as r
    where
      dashboard_name = 'github_tracker.dashboard.github_open_cli_pull_request_report'
    group by
      created_at
    order by
      created_at
  EOQ
}

query "github_issue_plugin_mod_trend" {
  sql = <<-EOQ
    select
      created_at as "Date",
      sum((r ->> 'Age in Days')::numeric) as "Days Open"
    from
      pipes_workspace_snapshot,
      jsonb_array_elements(data -> 'panels' -> 'github_tracker.table.container_dashboard_github_open_plugin_mod_issue_report_anonymous_container_0_anonymous_table_0' -> 'data' -> 'rows') as r
    where
      dashboard_name = 'github_tracker.dashboard.github_open_plugin_mod_issue_report'
    group by
      created_at
    order by
      created_at
  EOQ
}

query "github_pull_request_plugin_mod_trend" {
  sql = <<-EOQ
    select
      created_at as "Date",
      sum((r ->> 'Age in Days')::numeric) as "Days Open"
    from
      pipes_workspace_snapshot,
      jsonb_array_elements(data -> 'panels' -> 'github_tracker.table.container_dashboard_github_open_plugin_mod_pull_request_report_anonymous_container_0_anonymous_table_0' -> 'data' -> 'rows') as r
    where
      dashboard_name = 'github_tracker.dashboard.github_open_plugin_mod_pull_request_report'
    group by
      created_at
    order by
      created_at
  EOQ
}
