locals {
  github_repository_checks_common_tags = merge(local.github_common_tags, {
    service = "GitHub/Repository"
  })
}

benchmark "repository_checks" {
  title = "GitHub Repository Checks"
  children = [
    benchmark.mod_repository_checks,
    benchmark.plugin_mod_repository_checks,
    benchmark.plugin_repository_checks,
  ]

  tags = merge(local.github_repository_checks_common_tags, {
    type = "Benchmark"
  })
}

variable "github_external_repo_names" {
  type        = list(string)
  description = "A list of community repositories to run checks for."
  default     = [ "francois2metz/steampipe-plugin-ovh", "theapsgroup/steampipe-plugin-vault", "francois2metz/steampipe-plugin-scalingo", "francois2metz/steampipe-plugin-gandi", "francois2metz/steampipe-plugin-airtable", "theapsgroup/steampipe-plugin-gitlab", "ellisvalentiner/steampipe-plugin-confluence", "theapsgroup/steampipe-plugin-keycloak", "ip2location/steampipe-plugin-ip2locationio", "kaggrwal/steampipe-plugin-bitfinex", "mr-destructive/steampipe-plugin-cohereai", "solacelabs/steampipe-plugin-solace", "theapsgroup/steampipe-plugin-clickup", "ellisvalentiner/steampipe-plugin-weatherkit", "tomba-io/steampipe-plugin-tomba", "ernw/steampipe-plugin-openstack", "theapsgroup/steampipe-plugin-freshservice", "francois2metz/steampipe-plugin-freshping", "marekjalovec/steampipe-plugin-make", "francois2metz/steampipe-plugin-gitguardian", "francois2metz/steampipe-plugin-baleen" ]
}

benchmark "plugin_mod_repository_checks" {
  title = "GitHub Plugin and Mod Repository Checks"
  children = [
    # control.repo_has_no_collaborators,
    control.branch_protection_enabled,
    control.license_is_apache,
    control.repo_auto_merge_allowed,
    control.repo_forking_enabled,
    control.repo_homepage_links_to_hub,
    control.repo_is_public,
    control.repo_projects_disabled,
    control.repo_squash_merge_allowed,
    control.repo_web_commit_signoff_required,
    control.repo_wiki_disabled,
    control.vulnerability_alerts_enabled,
  ]

  tags = merge(local.github_repository_checks_common_tags, {
    type = "Benchmark"
  })
}

benchmark "plugin_repository_checks" {
  title = "GitHub Plugin Repository Checks"
  children = [
    control.plugin_repo_description,
    control.plugin_repo_has_mandatory_topics,
    control.plugin_repo_language_is_go,
    control.plugin_uses_semantic_versioning,
  ]

  tags = merge(local.github_repository_checks_common_tags, {
    type = "Benchmark"
  })
}

benchmark "mod_repository_checks" {
  title = "GitHub Mod Repository Checks"
  children = [
    control.mod_repo_has_mandatory_topics,
    control.mod_repo_language_is_hcl,
    control.mod_uses_monotonic_versioning,
  ]

  tags = merge(local.github_repository_checks_common_tags, {
    type = "Benchmark"
  })
}

control "plugin_repo_description" {
  title = "Plugin repo has standard description"
  sql = <<-EOT
    (
    select
      url as resource,
      case
        when description like 'Use SQL to instantly query %. Open source CLI. No DB required.' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ': ' || description as reason,
      name_with_owner
    from
      github_my_repository
    where
      name_with_owner like 'turbot/steampipe-plugin-%'
    )
    union
    (
    select
      url as resource,
      case
        when description like 'Use SQL to instantly query %. Open source CLI. No DB required.' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ': ' || description as reason,
      name_with_owner
    from
      github_repository
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
    )
  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

control "plugin_repo_has_mandatory_topics" {
  title = "Plugin repo has mandatory topics"
  sql = <<-EOT
    (
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
        github_my_repository,
        input
      where
        name_with_owner like 'turbot/steampipe-plugin-%'
    )
    select
      url as resource,
      case
        when has_mandatory_topics then 'ok'
        else 'alarm'
      end as status,
      case
        when has_mandatory_topics then name_with_owner || ' has all mandatory topics.'
        else name_with_owner || ' is missing topics ' || missing_topics
      end as reason,
      name_with_owner
    from
      analysis
    )
    union
    (
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
        github_repository,
        input
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
    )
    select
      url as resource,
      case
        when has_mandatory_topics then 'ok'
        else 'alarm'
      end as status,
      case
        when has_mandatory_topics then name_with_owner || ' has all mandatory topics.'
        else name_with_owner || ' is missing topics ' || missing_topics
      end as reason,
      name_with_owner
    from
      analysis
    )
  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

control "mod_repo_has_mandatory_topics" {
  title = "Mod repo has mandatory topics"
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
        github_my_repository,
        input
      where
        name_with_owner like 'turbot/steampipe-mod-%'
        and name_with_owner not like '%-wip'
    )
    select
      url as resource,
      case
        when has_mandatory_topics then 'ok'
        else 'alarm'
      end as status,
      case
        when has_mandatory_topics then name_with_owner || ' has all mandatory topics.'
        else name_with_owner || ' is missing topics ' || missing_topics
      end as reason,
      name_with_owner
    from
      analysis
  EOT
}

control "plugin_uses_semantic_versioning" {
  title = "Plugin uses semantic versioning"
  sql = <<-EOT
    (
    select
      r.url || '@' || t.name as resource,
      case
        when t.name ~ '^v[0-9]+\.[0-9]+\.[0-9]+$' then 'ok'
        when t.name ~ '^v[0-9]+\.[0-9]+\.[0-9]+' then 'info'
        else 'alarm'
      end as status,
      r.name_with_owner || '@' || t.name as reason,
      r.name_with_owner
    from
      github_my_repository as r,
      github_tag as t
    where
      r.name_with_owner like 'turbot/steampipe-plugin-%'
      and r.name_with_owner = t.repository_full_name
    )
    union
    (
    select
      r.url || '@' || t.name as resource,
      case
        when t.name ~ '^v[0-9]+\.[0-9]+\.[0-9]+$' then 'ok'
        when t.name ~ '^v[0-9]+\.[0-9]+\.[0-9]+' then 'info'
        else 'alarm'
      end as status,
      r.name_with_owner || '@' || t.name as reason,
      r.name_with_owner
    from
      github_repository as r,
      github_tag as t
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
      and r.name_with_owner = t.repository_full_name
    )

  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

control "mod_uses_monotonic_versioning" {
  title = "Mod uses monotonic versioning"
  sql = <<-EOT
    select
      r.url || '@' || t.name as resource,
      case
        when t.name ~ '^v[0-9]+\.[0-9]+$' then 'ok'
        when t.name ~ '^v[0-9]+\.[0-9]+' then 'info'
        else 'alarm'
      end as status,
      r.name_with_owner || '@' || t.name as reason,
      r.name_with_owner
    from
      github_my_repository as r,
      github_tag as t
    where
      r.name_with_owner like 'turbot/steampipe-mod-%'
      and r.name_with_owner not like '%-wip'
      and r.name_with_owner = t.repository_full_name
  EOT
}

control "license_is_apache" {
  title = "License is Apache 2.0"
  sql = <<-EOT
    (
    select
      url as resource,
      case
        when license_info ->> 'spdx_id' = 'Apache-2.0' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' license is ' || (license_info -> 'spdx_id')::text as reason,
      name_with_owner
    from
      github_my_repository
    where
      name_with_owner ~ '^turbot/steampipe-(mod|plugin)-.+'
      and name_with_owner not like '%-wip'
    )
    union
    (
    select
      url as resource,
      case
        when license_info ->> 'spdx_id' = 'Apache-2.0' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' license is ' || (license_info -> 'spdx_id')::text as reason,
      name_with_owner
    from
      github_repository
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
      and name_with_owner not like '%-wip'
    )

  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

control "vulnerability_alerts_enabled" {
  title = "Vulnerability Alerts are enabled"
  sql = <<-EOT
    (
    select
      url as resource,
      case
        when has_vulnerability_alerts_enabled then 'ok'
        else 'alarm'
      end as status,
      case
        when has_vulnerability_alerts_enabled then name_with_owner || ' vulnerability alerts enabled.'
        else name_with_owner || ' vulnerability alerts disabled.'
      end as reason,
      name_with_owner
    from
      github_my_repository
    where
      name_with_owner ~ '^turbot/steampipe-(mod|plugin)-.+'
      and name_with_owner not like '%-wip'
    )
    union
    (
    select
      url as resource,
      case
        when has_vulnerability_alerts_enabled then 'ok'
        else 'alarm'
      end as status,
      case
        when has_vulnerability_alerts_enabled then name_with_owner || ' vulnerability alerts enabled.'
        else name_with_owner || ' vulnerability alerts disabled.'
      end as reason,
      name_with_owner
    from
      github_repository
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
      and name_with_owner not like '%-wip'
    )

  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

control "branch_protection_enabled" {
  title = "Branch Protection is enabled"
  sql = <<-EOT
    (
    select
      url as resource,
      case
        when default_branch_ref -> 'branch_protection_rule' is not null then 'ok'
        else 'alarm'
      end as status,
      case
        when default_branch_ref -> 'branch_protection_rule' is not null then name_with_owner || ' branch protection enabled.'
        else name_with_owner || ' branch protection disabled.'
      end as reason,
      name_with_owner
    from
      github_my_repository
    where
      name_with_owner ~ '^turbot/steampipe-(mod|plugin)-.+'
      and name_with_owner not like '%-wip'
    )
    union
    (
    select
      url as resource,
      case
        when default_branch_ref -> 'branch_protection_rule' is not null then 'ok'
        else 'alarm'
      end as status,
      case
        when default_branch_ref -> 'branch_protection_rule' is not null then name_with_owner || ' branch protection enabled.'
        else name_with_owner || ' branch protection disabled.'
      end as reason,
      name_with_owner
    from
      github_repository
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
      and name_with_owner not like '%-wip'
    )

  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

control "repo_homepage_links_to_hub" {
  title = "Repo homepage links to the Hub"
  sql = <<-EOT
    (
    select
      url as resource,
      case
        when homepage_url like 'https://hub.%' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' homepage is ' || coalesce(homepage_url, 'not set') as reason,
      name_with_owner
    from
      github_my_repository
    where
      name_with_owner ~ '^turbot/steampipe-(mod|plugin)-.+'
      and name_with_owner not like '%-wip'
    )
    union
    (
    select
      url as resource,
      case
        when homepage_url like 'https://hub.%' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' homepage is ' || coalesce(homepage_url, 'not set') as reason,
      name_with_owner
    from
      github_repository
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
      and name_with_owner not like '%-wip'
    )

  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

control "repo_wiki_disabled" {
  title = "Repo Wiki is Disabled"
  sql = <<-EOT
    (
    select
      url as resource,
      case
        when has_wiki_enabled then 'alarm'
        else 'ok'
      end as status,
      name_with_owner || ' wiki is ' || has_wiki_enabled as reason,
      name_with_owner
    from
      github_my_repository
    where
      name_with_owner ~ '^turbot/steampipe-(mod|plugin)-.+'
      and name_with_owner not like '%-wip'
    )
    union
    (
    select
      url as resource,
      case
        when has_wiki_enabled then 'alarm'
        else 'ok'
      end as status,
      name_with_owner || ' wiki is ' || has_wiki_enabled as reason,
      name_with_owner
    from
      github_repository
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
      and name_with_owner not like '%-wip'
    )
  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

control "repo_projects_disabled" {
  title = "Repo Projects is Disabled"
  sql = <<-EOT
    (
    select
      url as resource,
      case
        when has_projects_enabled then 'alarm'
        else 'ok'
      end as status,
      name_with_owner || ' projects is ' || has_projects_enabled as reason,
      name_with_owner
    from
      github_my_repository
    where
      name_with_owner ~ '^turbot/steampipe-(mod|plugin)-.+'
      and name_with_owner not like '%-wip'
    )
    union
    (
    select
      url as resource,
      case
        when has_projects_enabled then 'alarm'
        else 'ok'
      end as status,
      name_with_owner || ' projects is ' || has_projects_enabled as reason,
      name_with_owner
    from
      github_repository
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
      and name_with_owner not like '%-wip'
    )

  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

// TODO - collaborators is currently both inside and outside, so not helpful here
# control "repo_has_no_collaborators" {
#   title = "Repo has no collaborators"
#   sql = <<-EOT
#     (
#     select
#       url as resource,
#       case
#         when jsonb_array_length(collaborator_logins) = 0 then 'alarm'
#         else 'ok'
#       end as status,
#       name_with_owner || ' has ' || jsonb_array_length(collaborator_logins) || ' collaborators.' as reason,
#       name_with_owner
#     from
#       github_my_repository
#     where
#       name_with_owner ~ '^turbot/steampipe-(mod|plugin)-.+'
#       and name_with_owner not like '%-wip'
#     )
#     union
#     (
#     select
#       url as resource,
#       case
#         when jsonb_array_length(collaborator_logins) = 0 then 'alarm'
#         else 'ok'
#       end as status,
#       name_with_owner || ' has ' || jsonb_array_length(collaborator_logins) || ' collaborators.' as reason,
#       name_with_owner
#     from
#       github_repository
#     where
#       full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
#       and name_with_owner not like '%-wip'
#     )

#   EOT
#   param "github_external_repo_names" {
#     description = "External repo names."
#     default     = var.github_external_repo_names
#   }
# }

control "plugin_repo_language_is_go" {
  title = "Plugin repository language is Go"
  sql = <<-EOT
    (
    select
      url as resource,
      case
        when primary_language ->> 'name' = 'Go' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' language is ' || (primary_language ->> 'name') as reason,
      name_with_owner
    from
      github_my_repository
    where
      name_with_owner like 'turbot/steampipe-plugin-%'
    )
    union
    (
    select
      url as resource,
      case
        when primary_language ->> 'name' = 'Go' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' language is ' || (primary_language ->> 'name')::text as reason,
      name_with_owner
    from
      github_repository
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
    )

  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

control "mod_repo_language_is_hcl" {
  title = "Mod repository language is HCL"
  sql = <<-EOT
    select
      url as resource,
      case
        when primary_language ->> 'name' = 'HCL' then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || ' language is ' || (primary_language ->> 'name')::text as reason,
      name_with_owner
    from
      github_my_repository
    where
      name_with_owner like 'turbot/steampipe-mod-%'
      and name_with_owner not like '%-wip'
  EOT
}

control "repo_is_public" {
  title = "Repository is public"
  sql = <<-EOT
    (
    select
      url as resource,
      case
        when visibility = 'public' then 'ok'
        else 'info'
      end as status,
      name_with_owner || ' visibility is ' || visibility as reason,
      name_with_owner
    from
      github_my_repository
    where
      name_with_owner ~ '^turbot/steampipe-(mod|plugin)-.+'
      and name_with_owner not like '%-wip'
    )
    union
    (
    select
      url as resource,
      case
        when visibility = 'public' then 'ok'
        else 'info'
      end as status,
      name_with_owner || ' visibility is ' || visibility as reason,
      name_with_owner
    from
      github_repository
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
      and name_with_owner not like '%-wip'
    )

  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

control "repo_squash_merge_allowed" {
  title = "Repository squash merging is allowed"
  sql = <<-EOT
    (
    select
      url as resource,
      case
        when squash_merge_allowed then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || case
        when squash_merge_allowed then ' squash merge allowed'
        else ' squash merge not allowed'
      end || '.' reason
    from
      github_my_repository
    where
      name_with_owner ~ '^turbot/steampipe-(mod|plugin)-.+'
      and name_with_owner not like '%-wip'
    )
    union
    (
    select
      url as resource,
      case
        when squash_merge_allowed then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || case
        when squash_merge_allowed then ' squash merge allowed'
        else ' squash merge not allowed'
      end || '.' reason
    from
      github_repository
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
      and name_with_owner not like '%-wip'
    )

  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

control "repo_auto_merge_allowed" {
  title = "Repository auto merging is allowed"
  sql = <<-EOT
    (
    select
      url as resource,
      case
        when auto_merge_allowed then 'alarm'
        else 'ok'
      end as status,
      name_with_owner || case
        when auto_merge_allowed then ' auto merge allowed'
        else ' auto merge not allowed'
      end || '.' reason
    from
      github_my_repository
    where
      name_with_owner ~ '^turbot/steampipe-(mod|plugin)-.+'
    )
    union
    (
    select
      url as resource,
      case
        when auto_merge_allowed then 'alarm'
        else 'ok'
      end as status,
      name_with_owner || case
        when auto_merge_allowed then ' auto merge allowed'
        else ' auto merge not allowed'
      end || '.' reason
    from
      github_repository
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
    )

  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

control "repo_forking_enabled" {
  title = "Repository forking is enabled"
  sql = <<-EOT
    (
    select
      url as resource,
      case
        when visibility = 'public' and forking_allowed then 'ok'
        when visibility = 'public' and not forking_allowed then 'alarm'
        else 'ok'
      end as status,
      name_with_owner || case
        when visibility = 'public' and forking_allowed then ' is public and forking is allowed'
        when visibility = 'public' and not forking_allowed then ' is public and forking is not allowed'
        else ' is private'
      end || '.' reason
    from
      github_my_repository
    where
      name_with_owner ~ '^turbot/steampipe-(mod|plugin)-.+'
    )
    union
    (
    select
      url as resource,
      case
        when visibility = 'public' and forking_allowed then 'ok'
        when visibility = 'public' and not forking_allowed then 'alarm'
        else 'ok'
      end as status,
      name_with_owner || case
        when visibility = 'public' and forking_allowed then ' is public and forking is allowed'
        when visibility = 'public' and not forking_allowed then ' is public and forking is not allowed'
        else ' is private'
      end || '.' reason
    from
      github_repository
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
    )

  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}

control "repo_web_commit_signoff_required" {
  title = "Repository web commit sign-off required"
  sql = <<-EOT
    (
    select
      url as resource,
      case
        when web_commit_signoff_required then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || case
        when web_commit_signoff_required then ' web commit sign off required'
        else ' web commit sign off not required'
      end || '.' reason
    from
      github_my_repository
    where
      name_with_owner ~ '^turbot/steampipe-(mod|plugin)-.+'
    )
    union
    (
    select
      url as resource,
      case
        when web_commit_signoff_required then 'ok'
        else 'alarm'
      end as status,
      name_with_owner || case
        when web_commit_signoff_required then ' web commit sign off required'
        else ' web commit sign off not required'
      end || '.' reason
    from
      github_repository
    where
      full_name in (select jsonb_array_elements_text(to_jsonb($1::text[])))
    )

  EOT
  param "github_external_repo_names" {
    description = "External repo names."
    default     = var.github_external_repo_names
  }
}
