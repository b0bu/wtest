APPLICATION_NAME ?= gowtest
DOCKER_USERNAME ?= maclighiche
GIT_HASH ?= $(shell git log --format="%h" -n 1)

buildamd64:
		nerdctl build --platform amd64 -t ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} app/

buildarm64:
		nerdctl build --platform arm64 -t ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} app/

push:
		nerdctl push ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH}

clean:
		rm -rf app/data/*

release: buildamd64 push