locals {
  github_organization_checks_common_tags = merge(local.github_common_tags, {
    service = "GitHub/Organization"
  })
}

benchmark "organization_checks" {
  title = "GitHub Organization Checks"
  children = [
    control.org_description_set,
    control.org_domain_verified,
    control.org_email_set,
    control.org_homepage_set,
    control.org_profile_pic_set,
    control.org_two_factor_authentication_required // This check is also available in github-insights mod
  ]

  tags = merge(local.github_organization_checks_common_tags, {
    type = "Benchmark"
  })
}

control "org_two_factor_authentication_required" {
  title       = "Two-factor authentication should be required for users in an organization"
  description = "Two-factor authentication makes it harder for unauthorized actors to access repositories and organizations."
  tags        = local.github_organization_checks_common_tags
  sql = <<-EOT
    select
      url as resource,
      case
        when two_factor_requirement_enabled is null then 'info'
        when two_factor_requirement_enabled then 'ok'
        else 'alarm'
      end as status,
      login ||
        case
          when two_factor_requirement_enabled is null then ' 2FA requirement unverifiable'
          when (two_factor_requirement_enabled)::bool then ' requires 2FA'
          else ' does not require 2FA'
        end || '.' as reason,
      login
    from
      github_my_organization;
  EOT
}

control "org_email_set" {
  title       = "Organization email should be set"
  description = "Setting an email provides useful contact information for users."
  tags        = local.github_organization_checks_common_tags
  sql = <<-EOT
    select
      url as resource,
      case
        when email is null then 'alarm'
        when email = '' then 'alarm'
        else 'ok'
      end as status,
      coalesce(name, login) || ' email is ' || case when (email is null) then 'not set' when (email = '') then 'not set' else email end || '.' as reason,
      login
    from
      github_my_organization;
  EOT
}

control "org_description_set" {
  title       = "Organization description should be set"
  description = "Setting a description helps users learn more about your organization."
  tags        = local.github_organization_checks_common_tags
  sql = <<-EOT
    select
      url as resource,
      case
        when description <> '' then 'ok'
        else 'alarm'
      end as status,
      coalesce(name, login) || ' description is ' || case when(description <> '') then description else 'not set' end || '.' as reason,
      login
    from
      github_my_organization;
  EOT
}

control "org_profile_pic_set" {
  title       = "Organization profile picture should be set"
  description = "Setting a profile picture helps users recognize your brand."
  tags        = local.github_organization_checks_common_tags
  sql = <<-EOT
    select
      url as resource,
      case
        when avatar_url is not null then 'ok'
        else 'alarm'
      end as status,
      coalesce(name, login) || ' profile picture URL is ' || case when(avatar_url <> '') then avatar_url else 'not set' end || '.' as reason,
      login
    from
      github_my_organization;
  EOT
}

control "org_profile_pic_set" {
  title       = "Organization profile picture should be set"
  description = "Setting a profile picture helps users recognize your brand."
  tags        = local.github_organization_checks_common_tags
  sql = <<-EOT
    select
      url as resource,
      case
        when avatar_url is not null then 'ok'
        else 'alarm'
      end as status,
      coalesce(name, login) || ' profile picture URL is ' || case when(avatar_url <> '') then avatar_url else 'not set' end || '.' as reason,
      login
    from
      github_my_organization;
  EOT
}

control "org_domain_verified" {
  title       = "Domain should be verified in an organization"
  description = "Verifying your domain helps to confirm the organization's identity and send emails to users with verified emails."
  tags        = local.github_organization_checks_common_tags
  sql = <<-EOT
    select
      url as resource,
      case
        when is_verified then 'ok'
        else 'alarm'
      end as status,
      coalesce(name, login) || ' domain is ' || case when (is_verified)::bool then 'verified' else 'not verified' end || '.' as reason,
      login
    from
      github_my_organization;
  EOT
}

control "org_homepage_set" {
  title       = "Organization homepage should be set"
  description = "Setting a homepage helps users learn more about your organization."
  tags        = local.github_organization_checks_common_tags
  sql = <<-EOT
    select
      url as resource,
      case
        when website_url is null then 'alarm'
        when website_url = '' then 'alarm'
        else 'ok'
      end as status,
      coalesce(name, login) || ' homepage is ' || case when (website_url is null) then 'not set' when (website_url = '') then 'not set' else website_url end || '.' as reason,
      login
    from
      github_my_organization;
  EOT
}
