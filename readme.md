test webapp app service

The terraform deploys a simple web app for the purposes of testing B2C authentication and various deployment and lifecylce patterns. In addition it deploys a buget with notifications and automation account which can toggle a policy on or off that allows or denies the creation of resources if the budget is exceeded. The idea being that of $10 reaches 100% consumption, budget action group triggers automation account which sets policy to "deny" for all resources. When the buget equals anything less that 100% realistically 80 or less the policy is updated to 'audit'.
```
terraform init -backend-config=backend.conf
```
build, (see makefile)
```
nerdctl build -t <user>/gowtest app/ # Containerfile used in app/
nerdctl run -d -p 8080:8080 --rm --name gowtest gowtest:<tag>
```
**ensure local image instance repository is named *\<user>/image* before pushing (check nerdctl images)**
```
nerdctl login -u <user> docker.io # prompted for pass
nerdctl tag gowtest:<tag> docker.io/<user>/gowtest:<tag>
nerdctl push <user>/gowtest:<tag>

nerdctl run -p 8080:8080 -it --rm --entrypoint "/bin/bash" --name gowtest <user>/gowtest:<tag>
```