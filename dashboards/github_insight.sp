dashboard "github_insight" {

  title = "GitHub Insights"

  tags = merge(local.github_insight_common_tags, {
    type = "Dashboard"
  })

  container {

    chart {
      title = "GitHub Open CLI Issues"
      type  = "line"
      query = query.cli_issues
      width = 6
    }

    chart {
      title = "GitHub Open CLI Pull Requests"
      type  = "line"
      query = query.cli_pull_requests
      width = 6
    }

    chart {
      title = "GitHub Open Plugin and Mod Issues"
      type  = "line"
      query = query.plugin_and_mod_issues
      width = 6
    }

    chart {
      title = "GitHub Open Plugin and Mod Pull Requests"
      type  = "line"
      query = query.plugin_and_mod_pull_requests
      width = 6
    }
  }

}

query "cli_issues" {
  sql = <<-EOQ
    select
      created_at as "Date",
      sum((r ->> 'Age in Days')::numeric) as "Total Days"
    from
      steampipecloud_workspace_snapshot,
      jsonb_array_elements(data -> 'panels' -> 'github_tracker.table.container_dashboard_github_open_cli_issue_report_anonymous_container_0_anonymous_table_0' -> 'data' -> 'rows') as r
    group by
      created_at
    order by
      created_at
  EOQ
}

query "cli_pull_requests" {
  sql = <<-EOQ
    select
      created_at as "Date",
      sum((r ->> 'Age in Days')::numeric) as "Total Days"
    from
      steampipecloud_workspace_snapshot,
      jsonb_array_elements(data -> 'panels' -> 'github_tracker.table.container_dashboard_github_open_cli_pull_request_report_anonymous_container_0_anonymous_table_0' -> 'data' -> 'rows') as r
    group by
      created_at
    order by
      created_at
  EOQ
}

query "plugin_and_mod_issues" {
  sql = <<-EOQ
    select
      created_at as "Date",
      sum((r ->> 'Age in Days')::numeric) as "Total Days"
    from
      steampipecloud_workspace_snapshot,
      jsonb_array_elements(data -> 'panels' -> 'github_tracker.table.container_dashboard_github_open_plugin_mod_issue_report_anonymous_container_0_anonymous_table_0' -> 'data' -> 'rows') as r
    group by
      created_at
    order by
      created_at
  EOQ
}

query "plugin_and_mod_pull_requests" {
  sql = <<-EOQ
    select
      created_at as "Date",
      sum((r ->> 'Age in Days')::numeric) as "Total Days"
    from
      steampipecloud_workspace_snapshot,
      jsonb_array_elements(data -> 'panels' -> 'github_tracker.table.container_dashboard_github_open_plugin_mod_pull_request_report_anonymous_container_0_anonymous_table_0' -> 'data' -> 'rows') as r
    group by
      created_at
    order by
      created_at
  EOQ
}
