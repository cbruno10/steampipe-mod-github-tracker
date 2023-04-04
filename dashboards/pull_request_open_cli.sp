dashboard "github_open_cli_pull_request_report" {

  title = "GitHub Open CLI Pull Requests"

  tags = merge(local.github_pull_request_external_common_tags, {
    type = "Report"
  })

  container {

    # Analysis
    card {
      sql   = query.github_pull_request_cli_external_count.sql
      width = 2
    }
    card {
      sql   = query.github_pull_request_sdk_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_pull_request_fdw_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_pull_request_docsexternal_count.sql
      width = 2
    }

    card {
      sql   = query.github_pull_request_open_cli_total_days_count.sql
      width = 2
    }

    table {
      sql = query.github_pull_request_cli_table.sql

      column "html_url" {
        display = "none"
      }

      column "Pull Request" {
        href = "{{.'html_url'}}"
      }
    }

  }

}

query "github_pull_request_open_cli_total_days_count" {
  sql = <<-EOQ
    select
      'Total' as label,
      case
        when sum(now()::date - created_at::date) is null then '0 days'
        else sum(now()::date - created_at::date) || ' days'
      end as value,
      case
        when sum(now()::date - created_at::date) > 30 then 'alert'
        else 'ok'
      end as type
    from
      github_search_pull_request
    where
      query = 'org:turbot is:open'
      and (repository_full_name ~ 'turbot/steampipe-(docs|fdw|plugin-sdk)' or repository_full_name = 'turbot/steampipe')
      and "user" ->> 'login' not in (
        select
          jsonb_array_elements_text(g.member_logins) as member_login
        from
          github_my_organization g
        where
          g.login = 'turbot'
       );
    EOQ
}

query "github_pull_request_cli_external_count" {
  sql = <<-EOQ
    select
      'CLI' as label,
      case
        when sum(now()::date - created_at::date) is null then '0 days'
        else sum(now()::date - created_at::date) || ' days'
      end as value,
      case
        when sum(now()::date - created_at::date) > 30 then 'alert'
        else 'ok'
      end as type
    from
      github_search_pull_request
    where
      query = 'org:turbot is:open'
      and repository_full_name = 'turbot/steampipe'
      and "user" ->> 'login' not in (
        select
          jsonb_array_elements_text(g.member_logins) as member_login
        from
          github_my_organization g
        where
          g.login = 'turbot'
       );
    EOQ
}

query "github_pull_request_sdk_external_count" {
  sql = <<-EOQ
    select
      'SDK' as label,
      case
        when sum(now()::date - created_at::date) is null then '0 days'
        else sum(now()::date - created_at::date) || ' days'
      end as value,
      case
        when sum(now()::date - created_at::date) > 30 then 'alert'
        else 'ok'
      end as type
    from
      github_search_pull_request
    where
      query = 'org:turbot is:open'
      and repository_full_name = 'turbot/steampipe-plugin-sdk'
      and "user" ->> 'login' not in (
        select
          jsonb_array_elements_text(g.member_logins) as member_login
        from
          github_my_organization g
        where
          g.login = 'turbot'
       );
    EOQ
}

query "github_pull_request_fdw_external_count" {
  sql = <<-EOQ
    select
      'FDW' as label,
      case
        when sum(now()::date - created_at::date) is null then 0
        else sum(now()::date - created_at::date)
      end as value,
      case
        when sum(now()::date - created_at::date) > 30 then 'alert'
        else 'ok'
      end as type
    from
      github_search_pull_request
    where
      query = 'org:turbot is:open'
      and repository_full_name = 'turbot/steampipe-fdw'
      and "user" ->> 'login' not in (
        select
          jsonb_array_elements_text(g.member_logins) as member_login
        from
          github_my_organization g
        where
          g.login = 'turbot'
       );
    EOQ
}


query "github_pull_request_docsexternal_count" {
  sql = <<-EOQ
    select
      'Docs' as label,
      case
        when sum(now()::date - created_at::date) is null then '0 days'
        else sum(now()::date - created_at::date) || ' days'
      end as value,
      case
        when sum(now()::date - created_at::date) > 30 then 'alert'
        else 'ok'
      end as type
    from
      github_search_pull_request
    where
      query = 'org:turbot is:open'
      and repository_full_name = 'turbot/steampipe-docs'
      and "user" ->> 'login' not in (
        select
          jsonb_array_elements_text(g.member_logins) as member_login
        from
          github_my_organization g
        where
          g.login = 'turbot'
       );
    EOQ
}

query "github_pull_request_cli_table" {
  sql = <<-EOQ
    select
      repository_full_name as "Repository",
      title as "Pull Request",
      now()::date - created_at::date as "Age in Days",
      now()::date - updated_at::date as "Last Updated (Days)",
      "user" ->> 'login' as "Author",
      html_url
    from
      github_search_pull_request
    where
      query = 'org:turbot is:open'
      and (repository_full_name ~ 'turbot/steampipe-(docs|fdw|plugin-sdk)' or repository_full_name = 'turbot/steampipe')
      and "user" ->> 'login' not in (
        select
          jsonb_array_elements_text(g.member_logins) as member_login
        from
          github_my_organization g
        where
          g.login = 'turbot'
        )
    order by
      "Age in Days" desc;
  EOQ
}
