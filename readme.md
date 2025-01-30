test webapp app service

terraform init -backend-config=backend.conf
nerdctl build -t gowtest app/ // Containerfile used in app/
nerdctl run -d -p 8080:80 --rm --name gowtest gowtest:0.0.1