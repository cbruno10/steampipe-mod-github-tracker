dashboard "github_open_issue_pull_request_graphs" {

  title = "GitHub Open Issue and Pull Request Graphs"

  tags = merge(local.github_common_tags, {
    type = "Dashboard"
  })

  container {

    chart {
      title = "Open CLI Issues"
      type  = "line"
      query = query.github_issue_cli_graph
      width = 6
    }

    chart {
      title = "Open CLI Pull Requests"
      type  = "line"
      query = query.github_pull_request_cli_graph
      width = 6
    }

    chart {
      title = "Open Plugin and Mod Issues"
      type  = "line"
      query = query.github_issue_plugin_mod_graph
      width = 6
    }

    chart {
      title = "Open Plugin and Mod Pull Requests"
      type  = "line"
      query = query.github_pull_request_plugin_mod_graph
      width = 6
    }
  }

}

query "github_issue_cli_graph" {
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

query "github_pull_request_cli_graph" {
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

query "github_issue_plugin_mod_graph" {
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

query "github_pull_request_plugin_mod_graph" {
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