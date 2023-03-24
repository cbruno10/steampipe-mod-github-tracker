locals {
  github_pull_request_external_common_tags = {
    service = "GitHub/PullRequest"
  }
}

dashboard "github_open_pull_request_report" {

  title = "GitHub Open Pull Requests Report"

  tags = merge(local.github_pull_request_external_common_tags, {
    type = "Report"
  })

  container {

    # Analysis
    card {
      sql   = query.github_pull_request_open_total_days_count.sql
      width = 2
    }
    card {
      sql   = query.github_pull_request_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_pull_request_tool_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_pull_request_doc_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_pull_request_plugin_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_pull_request_mod_external_count.sql
      width = 2
    }

    table {
      sql = query.github_pull_request_external_detail.sql

      column "html_url" {
        display = "none"
      }

      column "Pull Request" {
        href = "{{.'html_url'}}"
      }
    }

  }

}

query "github_pull_request_external_count" {
  sql = <<-EOQ
    select
      count(*) as "Open Pull Requests"
    from
      github_search_pull_request
    where
      query='org:turbot is:open'
      and (repository_full_name ~ 'turbot/steampipe-(docs|fdw|mod|plugin)' or repository_full_name = 'turbot/steampipe') -- SDK repo is called steampipe-plugin-sdk
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

query "github_pull_request_tool_external_count" {
  sql = <<-EOQ
    select
      count(*) as "Steampipe Pull Requests"
    from
      github_search_pull_request
    where
      query='org:turbot is:open'
      and (repository_full_name ~ 'turbot/steampipe-(fdw|plugin-sdk)' or repository_full_name = 'turbot/steampipe') -- Only include steampipe-plugin-sdk, not other steampipe-plugin-* repos
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

query "github_pull_request_doc_external_count" {
  sql = <<-EOQ
    select
      count(*) as "Docs Pull Requests"
    from
      github_search_pull_request
    where
      query='org:turbot is:open'
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

query "github_pull_request_plugin_external_count" {
  sql = <<-EOQ
    select
      count(*) as "Plugin Pull Requests"
    from
      github_search_pull_request
    where
      query='org:turbot is:open'
      and repository_full_name ~ 'turbot/steampipe-plugin'
      and repository_full_name <> 'turbot/steampipe-plugin-sdk'
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

query "github_pull_request_mod_external_count" {
  sql = <<-EOQ
    select
      count(*) as "Mod Pull Requests"
    from
      github_search_pull_request
    where
      query='org:turbot is:open'
      and repository_full_name ~ 'turbot/steampipe-mod'
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

query "github_pull_request_open_total_days_count" {
  sql = <<-EOQ
    select
      sum(now()::date - created_at::date) as "Total Days"
    from
      github_search_pull_request
    where
      query='org:turbot is:open'
      and (repository_full_name ~ 'turbot/steampipe-(docs|fdw|mod|plugin)' or repository_full_name = 'turbot/steampipe') -- SDK repo is called steampipe-plugin-sdk
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

query "github_pull_request_external_detail" {
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
      query='org:turbot is:open'
      and (repository_full_name ~ 'turbot/steampipe-(docs|fdw|mod|plugin)' or repository_full_name = 'turbot/steampipe') -- SDK repo is called steampipe-plugin-sdk
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
