### test webapp app service

The terraform deploys a simple web app for the purposes of testing B2C authentication and various deployment and lifecylce patterns. In addition it deploys a buget with notifications and automation account which can toggle a policy on or off that allows or denies the creation of resources if the budget is exceeded. The idea being that of $10 reaches 100% consumption, budget action group triggers automation account which sets policy to "deny" for all resources. When the buget equals anything less that 100% realistically 80 or less the policy is updated to 'audit'.

Since there's no way to distinguish create from delete api calls via azure policy, the deny action essentially freezes the resource group, no create or delete actions can be perform, it's rendered inert. The rg is still consuming resources but the deny at least stops deployments if the apex of the consumption was reached quickly, say in seconds or minutes. Stopping further actions for investigation. The forecast notification can then be used to preemptively to warn when the budget is no longer good enough for the work being performed or that something unexpected is happening, action can also be taken here. 

#### note about tagging

Thankfully dockers api returns consistently ordered tags which means deploying new app service version can easily be achieved with the `http` data block. The tag is preserved in state using `terraform_data` and will only update when the tag has changed, this is assumed to be a production repo so any new version should be released. 

#### terraform
running terraform a remote backend is assumed
```
terraform init -backend-config=backend.conf
```
#### build, (see Makefile)
```
nerdctl build -t <user>/gowtest app/ # Containerfile used in app/
nerdctl run -d -p 8080:8080 --rm --name gowtest gowtest:<tag>
```
ensure local image instance repository is named **\<user>/image** before pushing (check *nerdctl images* command)
```
nerdctl login -u <user> docker.io # prompted for pass
nerdctl tag gowtest:<tag> docker.io/<user>/gowtest:<tag>
nerdctl push <user>/gowtest:<tag>

nerdctl run -p 8080:8080 -it --rm --entrypoint "/bin/bash" --name gowtest <user>/gowtest:<tag>
```
useful on free plan check cpu consumed by the web app where sub_id is given as tf output
```
az monitor metrics list --resource "/subscriptions/0c0e5228-4139-4cc4-bfc0-8601fb17134a/resourceGroups/aspgowtestwebapp/providers/Microsoft.Web/sites/gowtest" --metric CPUTime --interval PT1H --query "value[0].timeseries[0].data[0].total"
```

#### requirements

create a `terraform.tfvars` file with the following variables. Including `docker_registry_` variables in the `application_stack` for the web app turns on private access to the the docker repository. Omitting them defaults to public.
```hcl
subscription_id          = ""
tenant_id                = ""
resource_group_name      = ""
docker_registry_password = "" (optional)
docker_registry_username = "" (optional)
```

create a `backend.conf` file with the following varables
```hcl
resource_group_name    = ""
storage_account_name   = ""
subscription_id        = ""
tenant_id              = ""
```