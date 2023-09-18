dashboard "github_open_cli_issue_report" {

  title = "GitHub Open CLI Issues"

  tags = merge(local.github_issue_external_common_tags, {
    type = "Report"
  })

  container {

    # Analysis
    card {
      sql   = query.github_issue_cli_external_count.sql
      width = 2
    }
    card {
      sql   = query.github_issue_sdk_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_issue_fdw_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_issue_docs_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_issue_open_cli_total_days_count.sql
      width = 2
    }

    table {
      sql = query.github_issue_cli_table.sql

      column "url" {
        display = "none"
      }

      column "Issue" {
        href = "{{.'url'}}"
      }
    }

  }

}

query "github_issue_open_cli_total_days_count" {
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
      github_search_issue
    where
      query = 'org:turbot is:open is:public'
      and (repository_full_name ~ 'turbot/steampipe-(docs|fdw|plugin-sdk)' or repository_full_name = 'turbot/steampipe')
      and author ->> 'login' not in (
        select
          m.login as member_login
        from
          github_organization_member m
        where
          m.organization = 'turbot'
       );
    EOQ
}

query "github_issue_cli_external_count" {
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
      github_search_issue
    where
      query = 'org:turbot is:open is:public'
      and repository_full_name = 'turbot/steampipe'
      and author ->> 'login' not in (
        select
          m.login as member_login
        from
          github_organization_member m
        where
          m.organization = 'turbot'
       );
    EOQ
}

query "github_issue_sdk_external_count" {
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
      github_search_issue
    where
      query = 'org:turbot is:open is:public'
      and repository_full_name = 'turbot/steampipe-plugin-sdk'
      and author ->> 'login' not in (
        select
          m.login as member_login
        from
          github_organization_member m
        where
          m.organization = 'turbot'
       );
    EOQ
}

query "github_issue_fdw_external_count" {
  sql = <<-EOQ
    select
      'FDW' as label,
      case
        when sum(now()::date - created_at::date) is null then '0 days'
        else sum(now()::date - created_at::date) || ' days'
      end as value,
      case
        when sum(now()::date - created_at::date) > 30 then 'alert'
        else 'ok'
      end as type
    from
      github_search_issue
    where
      query = 'org:turbot is:open is:public'
      and repository_full_name = 'turbot/steampipe-fdw'
      and author ->> 'login' not in (
        select
          m.login as member_login
        from
          github_organization_member m
        where
          m.organization = 'turbot'
       );
    EOQ
}

query "github_issue_docs_external_count" {
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
      github_search_issue
    where
      query = 'org:turbot is:open is:public'
      and repository_full_name = 'turbot/steampipe-docs'
      and author ->> 'login' not in (
        select
          m.login as member_login
        from
          github_organization_member m
        where
          m.organization = 'turbot'
       );
    EOQ
}

query "github_issue_cli_table" {
  sql = <<-EOQ
    select
      repository_full_name as "Repository",
      title as "Issue",
      now()::date - created_at::date as "Age in Days",
      now()::date - updated_at::date as "Last Updated (Days)",
      author ->> 'login' as "Author",
      url
    from
      github_search_issue
    where
      query = 'org:turbot is:open is:public'
      and (repository_full_name ~ 'turbot/steampipe-(docs|fdw|plugin-sdk)' or repository_full_name = 'turbot/steampipe')
      and author ->> 'login' not in (
        select
          m.login as member_login
        from
          github_organization_member m
        where
          m.organization = 'turbot'
        )
    order by
      "Age in Days" desc;
  EOQ
}
