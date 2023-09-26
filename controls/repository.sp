locals {
  github_repository_checks_common_tags = merge(local.github_common_tags, {
    service = "GitHub/Repository"
  })
}

# TODO: Remove this variable when not required
variable "github_external_repository_names" {
  type        = list(string)
  description = "A list of community repositories to run checks for."

  default = [
    "ellisvalentiner/steampipe-plugin-confluence",
    "ellisvalentiner/steampipe-plugin-weatherkit",
    "ernw/steampipe-plugin-openstack",
    "francois2metz/steampipe-plugin-airtable",
    "francois2metz/steampipe-plugin-baleen",
    "francois2metz/steampipe-plugin-freshping",
    "francois2metz/steampipe-plugin-gandi",
    "francois2metz/steampipe-plugin-gitguardian",
    "francois2metz/steampipe-plugin-ovh",
    "francois2metz/steampipe-plugin-scalingo",
    "ip2location/steampipe-plugin-ip2locationio",
    "kaggrwal/steampipe-plugin-bitfinex",
    "marekjalovec/steampipe-plugin-make",
    "mr-destructive/steampipe-plugin-cohereai",
    "solacelabs/steampipe-plugin-solace",
    "theapsgroup/steampipe-plugin-clickup",
    "theapsgroup/steampipe-plugin-freshservice",
    "theapsgroup/steampipe-plugin-gitlab",
    "theapsgroup/steampipe-plugin-keycloak",
    "theapsgroup/steampipe-plugin-vault",
    "tomba-io/steampipe-plugin-tomba",
  ]
}

# TODO: Update common queries to search for mod and plugin repos, or separate
# them out
benchmark "repository_checks" {
  title = "GitHub Repository Checks"
  children = [
    benchmark.repository_mod_checks,
    benchmark.repository_plugin_checks,
    benchmark.repository_steampipe_cli_fdw_sdk_docs_checks
  ]

  tags = merge(local.github_repository_checks_common_tags, {
    type = "Benchmark"
  })
}

benchmark "repository_mod_checks" {
  title = "GitHub Mod Repository Checks"
  children = [
    control.repository_mod_has_mandatory_topics,
    control.repository_mod_uses_monotonic_versioning,
    control.repository_mod_default_branch_protection_enabled,
    control.repository_mod_delete_branch_on_merge_enabled,
    control.repository_mod_homepage_links_to_hub,
    control.repository_mod_language_is_hcl,
    control.repository_mod_license_is_apache,
    control.repository_mod_merge_commit_squash_merge_allowed,
    control.repository_mod_projects_disabled,
    control.repository_mod_vulnerability_alerts_enabled,
    control.repository_mod_wiki_disabled,
  ]

  tags = merge(local.github_repository_checks_common_tags, {
    type = "Benchmark"
  })
}

benchmark "repository_plugin_checks" {
  title = "GitHub Plugin Repository Checks"
  children = [
    control.repository_plugin_has_mandatory_topics,
    control.repository_plugin_uses_semantic_versioning,
    control.repository_plugin_default_branch_protection_enabled,
    control.repository_plugin_delete_branch_on_merge_enabled,
    control.repository_plugin_description_is_set,
    control.repository_plugin_homepage_links_to_hub,
    control.repository_plugin_language_is_go,
    control.repository_plugin_license_is_apache,
    control.repository_plugin_projects_disabled,
    control.repository_plugin_squash_merge_allowed,
    control.repository_plugin_vulnerability_alerts_enabled,
    control.repository_plugin_wiki_disabled,
  ]

  tags = merge(local.github_repository_checks_common_tags, {
    type = "Benchmark"
  })
}

benchmark "repository_steampipe_cli_fdw_sdk_docs_checks" {
  title = "GitHub Steampipe CLI, FDW, SDK, Docs Repository Checks"
  children = [
    control.repository_steampipe_cli_fdw_sdk_docs_default_branch_protection_enabled,
    control.repository_steampipe_cli_fdw_sdk_docs_delete_branch_on_merge_enabled,
    control.repository_steampipe_cli_fdw_sdk_docs_description_is_set,
    control.repository_steampipe_cli_fdw_sdk_docs_language_is_go,
    control.repository_steampipe_cli_fdw_sdk_docs_license_is_apache,
    control.repository_steampipe_cli_fdw_sdk_docs_projects_disabled,
    control.repository_steampipe_cli_fdw_sdk_docs_squash_merge_allowed,
    control.repository_steampipe_cli_fdw_sdk_docs_vulnerability_alerts_enabled,
    control.repository_steampipe_cli_fdw_sdk_docs_wiki_disabled,
  ]

  tags = merge(local.github_repository_checks_common_tags, {
    type = "Benchmark"
  })
}

control "repository_plugin_description_is_set" {
  title = "Plugin repository has standard description"
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
      query = '${local.benchmark_all_plugin_search_query}'
    order by
      name_with_owner
  EOT
}

control "repository_plugin_has_mandatory_topics" {
  title = "Plugin repository has mandatory topics"
  sql = <<-EOT
    with input as (
      select array['sql', 'steampipe', 'steampipe-plugin', 'postgresql', 'postgresql-fdw'] as mandatory_topics
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
        query ='${local.benchmark_all_plugin_search_query}'
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

control "repository_mod_has_mandatory_topics" {
  title = "Mod repository has mandatory topics"
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

control "repository_plugin_uses_semantic_versioning" {
  title = "Plugin repository uses semantic versioning"
  sql = <<-EOT
    with repos as materialized (
      select
        url,
        name_with_owner
      from
        github_search_repository
      where
        query ='${local.benchmark_all_plugin_search_query}'
    )
    select
      r.url || '@' || t.name as resource,
      case
        when t.name ~ '^v[0-9]+\.[0-9]+\.[0-9]+$' then 'ok'
        else 'alarm'
      end as status,
      r.name_with_owner || '@' || t.name as reason,
      r.name_with_owner
    from
      repos as r,
      github_tag as t
    where
      r.name_with_owner = t.repository_full_name
      -- Exclude dev versions, e.g., v0.1.0+preview
      and t.name !~ '^v[0-9]+\.[0-9]+\.[0-9]+\+.*$'
    order by
      name_with_owner,
      tagger_date
  EOT
}

control "repository_mod_uses_monotonic_versioning" {
  title = "Mod repository uses monotonic versioning"
  sql = <<-EOT
    with repos as materialized (
      select
        url,
        name_with_owner
      from
        github_search_repository
      where
        query ='${local.benchmark_all_mod_search_query}'
    )
    select
      r.url || '@' || t.name as resource,
      case
        when t.name ~ '^v[0-9]+\.[0-9]+$' then 'ok'
        else 'alarm'
      end as status,
      r.name_with_owner || '@' || t.name as reason,
      r.name_with_owner
    from
      repos as r,
      github_tag as t
    where
      r.name_with_owner = t.repository_full_name
      -- Exclude dev versions, e.g., v0.9+preview
      and t.name !~ '^v[0-9]+\.[0-9]+\+.*$'
    order by
      name_with_owner,
      tagger_date
  EOT
}

control "repository_plugin_license_is_apache" {
  title = "Plugin repository license is Apache 2.0"
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
      query ='${local.benchmark_all_plugin_search_query}'
    order by
      name_with_owner
  EOT
}

# This control is mostly reliable for Turbot repos
control "repository_plugin_vulnerability_alerts_enabled" {
  title = "Plugin repository vulnerability alerts are enabled"
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
      query ='${local.benchmark_turbot_plugin_search_query}'
    order by
      name_with_owner
  EOT
}

# This control is mostly reliable for Turbot repos
control "repository_plugin_delete_branch_on_merge_enabled" {
  title = "Plugin repository delete branch on merge enabled"
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
      query = '${local.benchmark_turbot_plugin_search_query}'
    order by
      name_with_owner
  EOT
}

# This control is mostly reliable for Turbot repos
control "repository_mod_delete_branch_on_merge_enabled" {
  title = "Mod repository delete branch on merge enabled"
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
control "repository_plugin_default_branch_protection_enabled" {
  title = "Plugin repository default branch protection is enabled"
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
      query = '${local.benchmark_turbot_plugin_search_query}'
    order by
      name_with_owner
  EOT
}

control "repository_plugin_homepage_links_to_hub" {
  title = "Plugin repository homepage links to the Hub"
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
      query ='${local.benchmark_all_plugin_search_query}'
    order by
      name_with_owner
  EOT
}

control "repository_plugin_wiki_disabled" {
  title = "Plugin repository wiki is disabled"
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
      query ='${local.benchmark_all_plugin_search_query}'
    order by
      name_with_owner
  EOT
}

control "repository_plugin_projects_disabled" {
  title = "Plugin repository projects are disabled"
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
      query ='${local.benchmark_all_plugin_search_query}'
    order by
      name_with_owner
  EOT
}

control "repository_plugin_language_is_go" {
  title = "Plugin repository language is Go"
  sql = <<-EOT
    select
      url as resource,
      case
        when primary_language ->> 'name' = 'Go' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' language is ' || coalesce(((primary_language ->> 'name')::text), 'not set') || '.' as reason,
      name_with_owner
    from
      github_search_repository
    where
      query ='${local.benchmark_all_plugin_search_query}'
    order by
      name_with_owner
  EOT
}

# This control is only reliable for Turbot repos
control "repository_mod_default_branch_protection_enabled" {
  title = "Mod repository default branch protection is enabled"
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

control "repository_mod_homepage_links_to_hub" {
  title = "Mod repository homepage links to the Hub"
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

control "repository_mod_wiki_disabled" {
  title = "Mod repository wiki is disabled"
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

control "repository_mod_projects_disabled" {
  title = "Mod repository projects are disabled"
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

control "repository_mod_language_is_hcl" {
  title = "Mod repository language is HCL"
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

# This control is mostly reliable for Turbot repos
control "repository_mod_merge_commit_squash_merge_allowed" {
  title = "Mod repository allows merge commits and squash merging"
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

control "repository_mod_license_is_apache" {
  title = "Mod repository license is Apache 2.0"
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

# This control is mostly reliable for Turbot repos
control "repository_mod_vulnerability_alerts_enabled" {
  title = "Mod repository vulnerability alerts are enabled"
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

# This control is mostly reliable for Turbot repos
control "repository_plugin_squash_merge_allowed" {
  title = "Plugin repository allows squash merging"
  sql = <<-EOT
    select
      url as resource,
      case
        when not merge_commit_allowed and not rebase_merge_allowed and squash_merge_allowed then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || case
        when not merge_commit_allowed and not rebase_merge_allowed and squash_merge_allowed then ' only allows'
        else ' does not only allow'
      end || ' squash merging.' as reason,
      name_with_owner
    from
      github_search_repository
    where
      query = '${local.benchmark_turbot_plugin_search_query}'
    order by
      name_with_owner
  EOT
}

// Other checks

control "repository_steampipe_cli_fdw_sdk_docs_description_is_set" {
  title = "Steampipe CLI, FDW, SDK, Docs repositories have a standard description"
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
      query ='repo:turbot/steampipe repo:turbot/steampipe-plugin-sdk repo:turbot/steampipe-docs repo:turbot/steampipe-postgres-fdw is:public archived:false'
    order by
      name_with_owner
  EOT
}

control "repository_steampipe_cli_fdw_sdk_docs_has_mandatory_topics" {
  title = "Steampipe CLI, FDW, SDK, Docs repositories have mandatory topics"
  sql = <<-EOT
    with input as (
      select array['sql', 'steampipe', 'steampipe-plugin', 'postgresql', 'postgresql-fdw'] as mandatory_topics
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
      query ='repo:turbot/steampipe repo:turbot/steampipe-plugin-sdk repo:turbot/steampipe-docs repo:turbot/steampipe-postgres-fdw is:public archived:false'
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

control "repository_steampipe_cli_fdw_sdk_docs_uses_semantic_versioning" {
  title = "Steampipe CLI, FDW, SDK, Docs repositories use semantic versioning"
  sql = <<-EOT
    with repos as materialized (
      select
        url,
        name_with_owner
      from
        github_search_repository
      where
        query ='repo:turbot/steampipe repo:turbot/steampipe-plugin-sdk repo:turbot/steampipe-docs repo:turbot/steampipe-postgres-fdw is:public archived:false'
    )
    select
      r.url || '@' || t.name as resource,
      case
        when t.name ~ '^v[0-9]+\.[0-9]+\.[0-9]+$' then 'ok'
        else 'alarm'
      end as status,
      r.name_with_owner || '@' || t.name as reason,
      r.name_with_owner
    from
      repos as r,
      github_tag as t
    where
      r.name_with_owner = t.repository_full_name
      -- Exclude dev versions, e.g., v0.1.0+preview
      and t.name !~ '^v[0-9]+\.[0-9]+\.[0-9]+\+.*$'
    order by
      name_with_owner,
      tagger_date
  EOT
}

control "repository_steampipe_cli_fdw_sdk_docs_license_is_apache" {
  title = "Steampipe SDK repository uses Apache 2.0 license"
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
      query ='repo:turbot/steampipe-plugin-sdk is:public archived:false'
    order by
      name_with_owner
  EOT
}

# This control is mostly reliable for Turbot repos
control "repository_steampipe_cli_fdw_sdk_docs_vulnerability_alerts_enabled" {
  title = "Steampipe CLI, FDW, SDK, Docs repositories have vulnerability alerts enabled"
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
      query ='repo:turbot/steampipe repo:turbot/steampipe-plugin-sdk repo:turbot/steampipe-docs repo:turbot/steampipe-postgres-fdw is:public archived:false'
    order by
      name_with_owner
  EOT
}

# This control is mostly reliable for Turbot repos
control "repository_steampipe_cli_fdw_sdk_docs_delete_branch_on_merge_enabled" {
  title = "Steampipe CLI, FDW, SDK, Docs repositories have delete branch on merge enabled"
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
      query ='repo:turbot/steampipe repo:turbot/steampipe-plugin-sdk repo:turbot/steampipe-docs repo:turbot/steampipe-postgres-fdw is:public archived:false'
    order by
      name_with_owner
  EOT
}

# This control is only reliable for Turbot repos
control "repository_steampipe_cli_fdw_sdk_docs_default_branch_protection_enabled" {
  title = "Steampipe CLI, FDW, SDK, Docs repositories have default branch protection enabled"
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
      query ='repo:turbot/steampipe repo:turbot/steampipe-plugin-sdk repo:turbot/steampipe-docs repo:turbot/steampipe-postgres-fdw is:public archived:false'
    order by
      name_with_owner
  EOT
}

control "repository_steampipe_cli_fdw_sdk_docs_wiki_disabled" {
  title = "Steampipe CLI, FDW, SDK, Docs repositories have wiki disabled"
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
      query ='repo:turbot/steampipe repo:turbot/steampipe-plugin-sdk repo:turbot/steampipe-docs repo:turbot/steampipe-postgres-fdw is:public archived:false'
    order by
      name_with_owner
  EOT
}

control "repository_steampipe_cli_fdw_sdk_docs_projects_disabled" {
  title = "Steampipe CLI, FDW, SDK, Docs repositories have projects disabled"
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
      query ='repo:turbot/steampipe repo:turbot/steampipe-plugin-sdk repo:turbot/steampipe-docs repo:turbot/steampipe-postgres-fdw is:public archived:false'
    order by
      name_with_owner
  EOT
}

control "repository_steampipe_cli_fdw_sdk_docs_language_is_go" {
  title = "Steampipe CLI, FDW, SDK, Docs repositories have language set to Go"
  sql = <<-EOT
    select
      url as resource,
      case
        when primary_language ->> 'name' = 'Go' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' language is ' || coalesce(((primary_language ->> 'name')::text), 'not set') || '.' as reason,
      name_with_owner
    from
      github_search_repository
    where
      query ='repo:turbot/steampipe repo:turbot/steampipe-plugin-sdk repo:turbot/steampipe-postgres-fdw is:public archived:false'
    order by
      name_with_owner
  EOT
}

# This control is mostly reliable for Turbot repos
control "repository_steampipe_cli_fdw_sdk_docs_squash_merge_allowed" {
  title = "Steampipe CLI, FDW, SDK, Docs repositories allow squash merging"
  sql = <<-EOT
    select
      url as resource,
      case
        when not merge_commit_allowed and not rebase_merge_allowed and squash_merge_allowed then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || case
        when not merge_commit_allowed and not rebase_merge_allowed and squash_merge_allowed then ' only allows'
        else ' does not only allow'
      end || ' squash merging.' as reason,
      name_with_owner
    from
      github_search_repository
    where
      query ='repo:turbot/steampipe repo:turbot/steampipe-plugin-sdk repo:turbot/steampipe-docs repo:turbot/steampipe-postgres-fdw is:public archived:false'
    order by
      name_with_owner
  EOT
}
