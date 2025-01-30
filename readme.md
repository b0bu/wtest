test webapp app service
```
terraform init -backend-config=backend.conf
```
build
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