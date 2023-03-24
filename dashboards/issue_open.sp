locals {
  github_issue_external_common_tags = {
    service = "GitHub/Issue"
  }
}

dashboard "github_open_issue_report" {

  title = "GitHub Open Issues Report"

  tags = merge(local.github_issue_external_common_tags, {
    type = "Report"
  })

  container {

    # Analysis
    card {
      sql   = query.github_issue_open_total_days_count.sql
      width = 2
    }

    card {
      sql   = query.github_issue_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_issue_tool_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_issue_doc_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_issue_plugin_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_issue_mod_external_count.sql
      width = 2
    }

    table {
      sql = query.github_issue_external_detail.sql

      column "html_url" {
        display = "none"
      }

      column "Issue" {
        href = "{{.'html_url'}}"
      }
    }

  }

}

query "github_issue_external_count" {
  sql = <<-EOQ
    select
      count(*) as "Open Issues"
    from
      github_search_issue
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

query "github_issue_plugin_external_count" {
  sql = <<-EOQ
    select
      count(*) as "Plugin Issues"
    from
      github_search_issue
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

query "github_issue_tool_external_count" {
  sql = <<-EOQ
    select
      count(*) as "Steampipe Issues"
    from
      github_search_issue
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

query "github_issue_doc_external_count" {
  sql = <<-EOQ
    select
      count(*) as "Docs Issues"
    from
      github_search_issue
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


query "github_issue_mod_external_count" {
  sql = <<-EOQ
    select
      count(*) as "Mod Issues"
    from
      github_search_issue
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

query "github_issue_open_total_days_count" {
  sql = <<-EOQ
    select
      sum(now()::date - created_at::date) as "Total Days"
    from
      github_search_issue
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

query "github_issue_external_detail" {
  sql = <<-EOQ
    select
      repository_full_name as "Repository",
      title as "Issue",
      now()::date - created_at::date as "Age in Days",
      now()::date - updated_at::date as "Last Updated (Days)",
      "user" ->> 'login' as "Author",
      html_url
    from
      github_search_issue
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
