benchmark "repository_steampipe_mod_checks" {
  title = "Steampipe Mod Repository Checks"
  children = [
    control.repository_steampipe_mod_has_mandatory_topics,
    control.repository_steampipe_mod_default_branch_protection_enabled,
    control.repository_steampipe_mod_delete_branch_on_merge_enabled,
    control.repository_steampipe_mod_description_is_set,
    control.repository_steampipe_mod_homepage_links_to_hub,
    control.repository_steampipe_mod_language_is_hcl,
    control.repository_steampipe_mod_license_is_apache,
    control.repository_steampipe_mod_merge_commit_squash_merge_allowed,
    control.repository_steampipe_mod_projects_disabled,
    control.repository_steampipe_mod_vulnerability_alerts_enabled,
    control.repository_steampipe_mod_wiki_disabled,
  ]

  tags = merge(local.github_repository_common_tags, {
    type = "Benchmark"
  })
}

# This control is only reliable for Turbot repos
control "repository_steampipe_mod_delete_branch_on_merge_enabled" {
  title = "Steampipe mod repositories delete branch on merge enabled"
  sql = <<-EOT
    select
      url as resource,
      case
        when delete_branch_on_merge then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' delete branch on merge ' || case
        when delete_branch_on_merge then 'enabled'
        else 'disabled'
      end || '.' as reason,
      name_with_owner
    from
      github_search_repository
    where
      query = '${local.benchmark_turbot_mod_search_query}'
    order by
      name_with_owner
  EOT
}

# This control is only reliable for Turbot repos
control "repository_steampipe_mod_default_branch_protection_enabled" {
  title = "Steampipe mod repositories default branch protection is enabled"
  sql = <<-EOT
    select
      url as resource,
      case
        when default_branch_ref -> 'branch_protection_rule' is not null then 'ok'
        else 'alarm'
      end as status,
      case
        when default_branch_ref -> 'branch_protection_rule' is not null then name_with_owner || ' default branch protection enabled.'
        else name_with_owner || ' default branch protection disabled.'
      end as reason,
      name_with_owner
    from
      github_search_repository
    where
      query = '${local.benchmark_turbot_mod_search_query}'
    order by
      name_with_owner
  EOT
}

control "repository_steampipe_mod_description_is_set" {
  title = "Steampipe mod repositories have a description"
  sql = <<-EOT
    select
      url as resource,
      case
        when description is not null then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || case
        when description != '' then ': ' || description
        else ' description not set'
      || '.' end as reason,
      name_with_owner
    from
      github_search_repository
    where
      query = '${local.benchmark_all_mod_search_query}'
    order by
      name_with_owner
  EOT
}

control "repository_steampipe_mod_homepage_links_to_hub" {
  title = "Steampipe mod repositories homepage links to the Hub"
  sql = <<-EOT
    select
      url as resource,
      case
        when homepage_url like 'https://hub.%' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' homepage is ' || case
        when homepage_url = '' then 'not set'
        else homepage_url
      end || '.' as reason,
      name_with_owner
    from
      github_search_repository
    where
      query = '${local.benchmark_all_mod_search_query}'
    order by
      name_with_owner
  EOT
}

control "repository_steampipe_mod_wiki_disabled" {
  title = "Steampipe mod repositories wiki is disabled"
  sql = <<-EOT
    select
      url as resource,
      case
        when has_wiki_enabled then 'alarm'
        else 'ok'
      end as status,
      name_with_owner || ' wiki is ' || case
        when has_wiki_enabled then 'enabled'
        else 'disabled'
      end || '.' as reason,
      name_with_owner
    from
      github_search_repository
    where
      query = '${local.benchmark_all_mod_search_query}'
    order by
      name_with_owner
  EOT
}

control "repository_steampipe_mod_projects_disabled" {
  title = "Steampipe mod repositories projects are disabled"
  sql = <<-EOT
    select
      url as resource,
      case
        when has_projects_enabled then 'alarm'
        else 'ok'
      end as status,
      name_with_owner || ' projects are ' || case
        when has_projects_enabled then 'enabled'
        else 'disabled'
      end || '.' as reason,
      name_with_owner
    from
      github_search_repository
    where
      query = '${local.benchmark_all_mod_search_query}'
    order by
      name_with_owner
  EOT
}

control "repository_steampipe_mod_language_is_hcl" {
  title = "Steampipe mod repositories language is HCL"
  sql = <<-EOT
    select
      url as resource,
      case
        when primary_language ->> 'name' = 'HCL' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' language is ' || coalesce(((primary_language ->> 'name')::text), 'not set') || '.' as reason,
      name_with_owner
    from
      github_search_repository
    where
      query ='${local.benchmark_all_mod_search_query}'
    order by
      name_with_owner
  EOT
}

# This control is only reliable for Turbot repos
control "repository_steampipe_mod_merge_commit_squash_merge_allowed" {
  title = "Steampipe mod repositories allow merge commits and squash merging"
  sql = <<-EOT
    select
      url as resource,
      case
        when merge_commit_allowed and not rebase_merge_allowed and squash_merge_allowed then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || case
        when not merge_commit_allowed and not rebase_merge_allowed and squash_merge_allowed then ' only allows'
        else ' does not only allow'
      end || ' merge commits and squash merging.' as reason,
      name_with_owner
    from
      github_search_repository
    where
      query = '${local.benchmark_turbot_mod_search_query}'
    order by
      name_with_owner
  EOT
}

control "repository_steampipe_mod_license_is_apache" {
  title = "Steampipe mod repositories license is Apache 2.0"
  sql = <<-EOT
    select
      url as resource,
      case
        when license_info ->> 'spdx_id' = 'Apache-2.0' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' license is ' || coalesce(((license_info -> 'spdx_id')::text), 'not set') || '.' as reason,
      name_with_owner
    from
      github_search_repository
    where
      query ='${local.benchmark_all_mod_search_query}'
    order by
      name_with_owner
  EOT
}

# This control is only reliable for Turbot repos
control "repository_steampipe_mod_vulnerability_alerts_enabled" {
  title = "Steampipe mod repositories vulnerability alerts are enabled"
  sql = <<-EOT
    select
      url as resource,
      case
        when has_vulnerability_alerts_enabled then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' vulnerability alerts ' || case
        when has_vulnerability_alerts_enabled then 'enabled'
        else 'disabled'
      end || '.' as reason,
      name_with_owner
    from
      github_search_repository
    where
      query ='${local.benchmark_turbot_mod_search_query}'
    order by
      name_with_owner
  EOT
}

control "repository_steampipe_mod_has_mandatory_topics" {
  title = "Steampipe mod repositories have mandatory topics"
  sql = <<-EOT
    with input as (
      select array['sql', 'steampipe', 'steampipe-mod'] as mandatory_topics
    ),
    analysis as (
      select
        url,
        topics ?& (input.mandatory_topics) as has_mandatory_topics,
        to_jsonb(input.mandatory_topics) - array(select jsonb_array_elements_text(topics)) as missing_topics,
        name_with_owner
      from
        github_search_repository,
        input
      where
        query ='${local.benchmark_all_mod_search_query}'
    )
    select
      url as resource,
      case
        when has_mandatory_topics then 'ok'
        else 'alarm'
      end as status,
      case
        when has_mandatory_topics then name_with_owner || ' has all mandatory topics.'
        else name_with_owner || ' is missing topics ' || missing_topics || '.'
      end as reason,
      name_with_owner
    from
      analysis
    order by
      name_with_owner
  EOT
}
