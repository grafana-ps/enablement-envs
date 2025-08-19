# Terraform Deep Dive Stacks

## Summary

The Terraform deep dive stacks illustrate the setup discussed in the infrastructure-as-code deep dive webinar.
The modules folder contains re-usable components across projects like the "stack" module.
The rest of the folders are individual projects corresponding to the use cases described in the video

Refer to the official docs for more details:

- [Grafana end-user doc](https://grafana.com/docs/grafana-cloud/developer-resources/infrastructure-as-code/terraform/terraform-cloud-stack/)
- [Terraform provider doc](https://registry.terraform.io/providers/grafana/grafana/latest/docs)

## Pre-reqs

- Grafana account/org
- Terraform

## General Usage

1. Create a "Root/Bootstrap" Access Policy in your Grafana Org portal under Security -> Access Policies

1. For these examples, you can select the following scopes:

    - accesspolicies:read
    - accesspolicies:delete
    - accesspolicies:write
    - dashboards:read
    - dashboards:write
    - dashboards:delete
    - orgs:read
    - orgs:write
    - stack-dashboards:read
    - stack-dashboards:write
    - stack-dashboards:delete
    - stack-service-accounts:write
    - stacks:read
    - stacks:write
    - stacks:delete

1. Create and copy a token for that policy
1. Navigate to one of the project folders and create a terraform.tfvars.json containing the created token:

    Example:

    ```json
    {
        "cloud_access_policy_token": "glc_eyJvIjoiM..."
    }
    ```

1. Run `terraform init` then `terraform apply`

## Architecture

### Provider Setup

*WARNING* The usage of a provider block inside a module is highly discouraged by Terraform and is only supported for legacy reasons.

This is the reason why the various Grafana provider declarations are defined at the root of each project and passed down to the sub-modules. Similarly, the stack resources are always declared in sub-modules, regardless of whether you are managing 1 or multiple stacks in a single project.

The main idea behind managing Grafana providers in that way is that the grafana cloud provider with the root token is only used to create the stacks. After that, the output of the stack module contains the stack specific tokens which are then used to create the "stack provider". The stack provider is then passed down to the specific stack module, which avoids having to specify the `provider = ...` in all the resources declared in that module.

### Setup Selection

The most straightforward setup is the `bootstrap` setup, in a "all-in-one" configuration. Everyone with access to the terraform project (in git for example), can contribute anything to the entire Grafana org, but you still have clear separation of stacks using modules. You can then control changes through pull requests but this approach can lead to regressions if the peer reviews are not thorough.

The `single-stack` setup is to give a team access to an existing stack. This configuration prevents teams from creating new stacks, but allows them to manage their own stack fully with the authentication token being a stack admin. Again, you can use PR to control who can make updates to the stack and only give "Editor" role to the service account.

The `team` setup is the most granular and allows a team to manage only a specific portion of a stack through restrictive service account tokens, *reducing the risk of regressions, blast radius and need for PRs*. In this configuration, you would typically create one terraform project per service account.

You are encouraged to use any combination of those 3. A typical secure and practical setup would consist of one `bootstrap` project with a root token to bootstrap 1 or more stacks, alongside 1 or more `team` projects. In this configuration, the `bootstrap` project only deals with the creation of stack(s) and teams/sso within stack(s). Alternatively, you can deploy 1 or more `single-stack` projects to delegate individual stack management to stack admins.

### Shared Stack Module

The modules/stack module is used to abstract the creation of a stack and associated resources like service accounts and optional installations for k6s and synthetic monitoring.

To use the module, you need to specify the name and slug for the stack, the products you want to enable as well as the root access token for your organization.

The module output contains the stack specific authentication information for the various APIs.

You can see an example of this module being used in the bootstrap/main.tf file.

### The "bootstrap" Project

This project shows an example of an organization that supports the management of 1 or more stacks in a single place. This is in contrast to the single-stack project where each stack is managed in its own project.

1. The main.tf file declares a `stack-1` module which initializes a new stack with everything enabled
1. It then declares the `my_stack_provider` provider using the output of the `stack_1`
1. Finally it declares the `my_stack` module and passes down the `my_stack_provider` provider
1. The `my_stack` subfolder contains the definition of the `my_stack` module with all the stack resources

You can see an example of a folder declaration under bootstrap/my_stack/folder.tf, and notice the provider reference is not explicitly passed to the resource, as it automatically inherits the `my_stack_provider`.

You can repeat the same process to create multiple stacks from this centralized location.

Pros:

- Easy to setup
- Everything in one place
- No need to pass tokens around

Cons (in all-in-one configuration):

- Anyone with access to the project can create/delete anything
- Lots of stacks with large amount of resources might not scale well

### The "single-stack" Project

This project is used to manage the content of a single stack. It follows the same concept as `bootstrap` with some notable differences:

1- it does not create the stack, and all the authentication tokens are passed as external variables to the provider
1- the stack resources are stored inside the `resources` folder

This setup is a good way to delegate the management of an entire stack to a specific team. Note that Grafana doesn't necessarily recommend creating multiple stacks aligned to teams, when you can instead use the RBAC/teams feature in a single stack, which is described in the `teams` setup, and works in most cases. Collecting data in multiple stacks can present challenges around sharing and authentication for example.

As mentioned before, the managed stack must have been created previously, with the optional installations for k6s and synthetics, either manually, or through a "bootstrap" setup. This setup allows teams to manage their own stack as stack admins, without having access to the root token and creating additional stacks.

When using the "bootstrap" setup to create the initial stack, you can add some declarations in the main project to upload the created tokens in a secret vault such as AWS Parameters/Secrets store or hashicorp vault, etc. Alternatively, you can also expose the created stack as an output so you can be copy the generated tokens in the stack project.

Example:

```hcl
output "stack_1" {
    value = module.stack_1
}
```

Pros:

- 1 project/repo per stack
- Prevents creation of additional stacks

Cons:

- Not encouraged when RBAC teams can be used instead
- Anyone with access to the project can create/delete anything in the stack

### The "team" Project

This setup is used to allow a single team to manage their own resources in one stack. This can be useful when multiple teams share the same stack but don't want to allow everyone to control all the resources in that stack.

In that scenario, a stack admin would have previously created the necessary permissions for this team by:

- creating a stack
- creating a team in that stack
- creating a service account for that team (just a standard service account)
- (optionally) creating a role for that team
- assigning the correct roles to the team and the service account
- generated the necessary token(s) for the service account

The terraform project is similar to the "single-stack" but here the service account token is even more restrictive, only allowing specific actions on the stack for the given team, as defined in the service account role.

Pros:

- 1 project/repo per team
- Leverages RBAC
- Limits blast radius of changes
- Fast deployments

Cons:

- Requires more planning
- Limited sharing
