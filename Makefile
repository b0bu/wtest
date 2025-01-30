APPLICATION_NAME ?= gowtest
DOCKER_USERNAME ?= maclighiche
VERSION ?= 0.0.2
GIT_HASH ?= $(shell git log --format="%h" -n 1)
 
build:
		nerdctl build -t ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} app/

push:
		nerdctl push ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH}

clean:
		rm -rf app/data/*

release: build push