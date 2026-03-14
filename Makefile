GHC_VERSION=9.6.7
CABAL_VERSION=3.12.1.0

bootstrap: build
	cp app/dist-al2023/build/x86_64-linux/ghc-${GHC_VERSION}/lambda-hello-world-0.1.0.0/x/bootstrap/build/bootstrap/bootstrap ./bootstrap
.PHONY: bootstrap

build: image
	mkdir -p .cabal-cache
	docker run --rm \
		--network host \
		-v $(PWD)/app:/app:z \
		-v $(PWD)/.cabal-cache:/home/$(shell id -un)/.local/state/cabal:z \
		-u $(shell id -un) \
		lambda-hello-world-build-env:latest \
	    cabal build --builddir=dist-al2023
.PHONY: build

image:
	docker build \
		--build-arg UID="$(shell id -u)" \
		--build-arg GID="$(shell id -g)" \
		--build-arg USER=$(shell id -un) \
		--build-arg CABAL_VERSION=${CABAL_VERSION} \
		--build-arg GHC_VERSION=${GHC_VERSION} \
		--network host -t lambda-hello-world-build-env .
.PHONY: image
