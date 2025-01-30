test webapp app service
```
terraform init -backend-config=backend.conf
```
build
```
nerdctl build -t <user>/gowtest app/ # Containerfile used in app/
nerdctl run -d -p 8080:80 --rm --name gowtest gowtest:0.0.1
```
**ensure local image instance repository is named *\<user>/image* before pushing (check nerdctl images)**
```
nerdctl login -u <username> docker.io # prompted for pass
nerdctl tag gowtest:0.0.1 docker.io/<user>/gowtest:0.0.1
nerdctl push <user>/gowtest:0.0.1
```