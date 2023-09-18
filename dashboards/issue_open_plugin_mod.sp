dashboard "github_open_plugin_mod_issue_report" {

  title = "GitHub Open Plugin and Mod Issues"

  tags = merge(local.github_issue_external_common_tags, {
    type = "Report"
  })

  container {

    # Analysis
    card {
      sql   = query.github_issue_aws_plugin_external_count.sql
      width = 2
    }

    card {
      sql   = query.github_issue_aws_compliance_mod_external_count.sql
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

    card {
      sql   = query.github_issue_open_plugin_mod_total_days_count.sql
      width = 2
    }

    table {
      sql = query.github_issue_open_plugin_mod_table.sql

      column "url" {
        display = "none"
      }

      column "Issue" {
        href = "{{.'url'}}"
      }
    }

  }

}

query "github_issue_aws_plugin_external_count" {
  sql = <<-EOQ
    select
      'AWS Plugin' as label,
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
      and repository_full_name = 'turbot/steampipe-plugin-aws'
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

query "github_issue_aws_compliance_mod_external_count" {
  sql = <<-EOQ
    select
      'AWS Compliance' as label,
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
      and repository_full_name = 'turbot/steampipe-mod-aws-compliance'
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

query "github_issue_open_plugin_mod_total_days_count" {
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
      and repository_full_name ~ 'turbot/steampipe-(plugin|mod)'
      and repository_full_name <> 'turbot/steampipe-plugin-sdk'
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

query "github_issue_plugin_external_count" {
  sql = <<-EOQ
    select
      'Plugins' as label,
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
      and repository_full_name ~ 'turbot/steampipe-plugin'
      and repository_full_name <> 'turbot/steampipe-plugin-sdk'
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

query "github_issue_mod_external_count" {
  sql = <<-EOQ
    select
      'Mods' as label,
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
      and repository_full_name ~ 'turbot/steampipe-mod'
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

query "github_issue_open_plugin_mod_table" {
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
      and repository_full_name ~ 'turbot/steampipe-(plugin|mod)'
      and repository_full_name <> 'turbot/steampipe-plugin-sdk'
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
