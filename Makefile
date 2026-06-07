GHC_VERSION=9.6.7
CABAL_VERSION=3.12.1.0

bootstrap:
	docker buildx build \
		--build-arg CABAL_VERSION=${CABAL_VERSION} \
		--build-arg GHC_VERSION=${GHC_VERSION} \
		--target artifact \
		--output type=local,dest=. .
.PHONY: bootstrap
