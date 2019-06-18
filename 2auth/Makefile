GIT_SHA := $(shell git rev-parse --short HEAD)

docker:
	docker build . --target prod -t eu.gcr.io/xamaral/2auth:$(GIT_SHA) -t 2auth:latest

push: docker
	docker push eu.gcr.io/xamaral/2auth:$(GIT_SHA)

docker-dev:
	docker build . --target dev -t 2auth-dev:latest

.PHONY: docker push docker-dev
