APPLICATION_NAME ?= gowtest
DOCKERHUB_USERNAME ?= maclighiche
GIT_HASH ?= $(shell git log --format="%h" -n 1)
PLATFORM ?= $(shell uname -s)

nerdbuildamd64:
		nerdctl build --platform amd64 -t ${DOCKERHUB_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} app/

nerdbuildarm64:
		nerdctl build --platform arm64 -t ${DOCKERHUB_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} app/

dockerbuildamd64:
		docker build --platform amd64 -t ${DOCKERHUB_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} -f Containerfile app/

dockerbuildarm64:
		docker build --platform arm64 -t ${DOCKERHUB_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} -f Containerfile app/

nerdpush:
		nerdctl push ${DOCKERHUB_USERNAME}/${APPLICATION_NAME}:${GIT_HASH}

dockerpush:
		nerdctl push ${DOCKERHUB_USERNAME}/${APPLICATION_NAME}:${GIT_HASH}

$(info Checking platform...)
ifeq ($(PLATFORM), Darwin)
	platform_specific_build := nerdbuildamd64
	platform_specific_push := nerdpush
else
	platform_specific_build := dockerbuildamd64
	platform_specific_push := dockerpush
endif


build: $(platform_specific_build)
push: $(platform_specific_push)

clean:
		rm -rf app/data/*

release: build push
